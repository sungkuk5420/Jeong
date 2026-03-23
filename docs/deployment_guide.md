# Jeong 배포 가이드

## 아키텍처

```
[Flutter App (iOS/Android)]
  ├──→ Supabase Cloud (DB, Auth, Realtime)
  └──→ Azure App Service (NestJS API)
         ├── /api/naver-map/*   (Puppeteer + Naver API)
         └── /api/diningcode/*  (맛집 검색)
```

## 1. Supabase 설정

1. https://supabase.com 에서 프로젝트 생성
2. SQL Editor에서 마이그레이션 실행:
   - `supabase/migrations/001_initial_schema.sql`
   - `supabase/migrations/002_seed_data.sql`
3. Authentication > Providers에서 Google, Apple OAuth 활성화
4. Settings > API에서 URL과 anon key 복사 → `client/.env`에 입력

## 2. NestJS 서버 → Azure 배포

### 사전 준비

- Azure CLI 설치: https://learn.microsoft.com/cli/azure/install-azure-cli
- Docker Desktop 설치

### Step 1: Azure 리소스 생성

```bash
# 로그인
az login

# 리소스 그룹 생성
az group create --name rg-jeong --location koreacentral

# Azure Container Registry 생성
az acr create --resource-group rg-jeong --name jeongacr --sku Basic

# App Service Plan 생성 (B1 이상 - Puppeteer 메모리 필요)
az appservice plan create \
  --name plan-jeong \
  --resource-group rg-jeong \
  --sku B1 \
  --is-linux

# Web App 생성 (컨테이너 기반)
az webapp create \
  --resource-group rg-jeong \
  --plan plan-jeong \
  --name jeong-api \
  --deployment-container-image-name jeongacr.azurecr.io/jeong-server:latest
```

### Step 2: Docker 이미지 빌드 & 푸시

```bash
cd server

# ACR 로그인
az acr login --name jeongacr

# 이미지 빌드 & 푸시
docker build -t jeongacr.azurecr.io/jeong-server:latest .
docker push jeongacr.azurecr.io/jeong-server:latest
```

### Step 3: 환경 변수 설정

```bash
az webapp config appsettings set \
  --resource-group rg-jeong \
  --name jeong-api \
  --settings \
    NAVER_CLIENT_ID=your_naver_client_id \
    NAVER_CLIENT_SECRET=your_naver_client_secret \
    DININGCODE_BASE_URL=https://www.diningcode.com \
    PORT=8080 \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
```

### Step 4: ACR → App Service 연결

```bash
# ACR admin 활성화
az acr update --name jeongacr --admin-enabled true

# ACR 자격증명 가져오기
az acr credential show --name jeongacr

# App Service에 컨테이너 레지스트리 설정
az webapp config container set \
  --resource-group rg-jeong \
  --name jeong-api \
  --container-image-name jeongacr.azurecr.io/jeong-server:latest \
  --container-registry-url https://jeongacr.azurecr.io \
  --container-registry-user jeongacr \
  --container-registry-password <ACR_PASSWORD>
```

### Step 5: 배포 확인

```bash
# 로그 확인
az webapp log tail --resource-group rg-jeong --name jeong-api

# 헬스 체크
curl https://jeong-api.azurewebsites.net/
# → "Hello World!" 반환되면 성공
```

## 3. Flutter 앱 설정

### .env 업데이트 (배포 후)

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
API_BASE_URL=https://jeong-api.azurewebsites.net
```

### 앱 빌드

```bash
cd client

# Android
flutter build apk --release
flutter build appbundle --release  # Play Store용

# iOS
flutter build ipa --release  # App Store용
```

## 4. 로컬 개발 환경

```bash
# NestJS 서버 (로컬)
cd server
npm run start:dev

# Docker로 실행 (로컬)
cd server
docker-compose up

# Flutter 앱 (로컬)
cd client
flutter run
```

로컬 개발 시 `client/.env`의 `API_BASE_URL`:
- Android 에뮬레이터: `http://10.0.2.2:3000`
- iOS 시뮬레이터: `http://localhost:3000`
- 실기기: `http://<PC_IP>:3000`

## 5. 비용 예상 (월)

| 서비스 | 플랜 | 예상 비용 |
|---|---|---|
| Supabase | Free (500MB DB) | $0 |
| Azure App Service | B1 | ~$13 |
| Azure Container Registry | Basic | ~$5 |
| **합계** | | **~$18/월** |

> 트래픽 증가 시 App Service를 B2/S1으로 스케일업하면 됩니다.
