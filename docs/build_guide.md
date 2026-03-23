# Jeong 앱 빌드 & 배포 가이드

## 1. Android 빌드 (Windows 로컬)

### 1.1 디버그 빌드 (개발/테스트)

```bash
cd client
flutter run                          # 에뮬레이터/연결된 디바이스에서 실행
flutter build apk --debug           # 디버그 APK 생성
```

### 1.2 릴리즈 빌드 준비

#### Step 1: Keystore 생성 (최초 1회)

```bash
# client/android/keystore/ 폴더 생성
mkdir -p android/keystore

# Keystore 생성
keytool -genkey -v \
  -keystore android/keystore/jeong-release.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias jeong
```

> ⚠️ **중요**: keystore 파일과 비밀번호는 절대 잃어버리면 안 됩니다.
> Play Store에 등록된 앱은 같은 keystore로만 업데이트 가능합니다.

#### Step 2: key.properties 설정

```bash
# key.properties.example을 복사
cp android/key.properties.example android/key.properties

# 실제 비밀번호로 수정
# storePassword=실제비밀번호
# keyPassword=실제비밀번호
# keyAlias=jeong
# storeFile=../keystore/jeong-release.jks
```

#### Step 3: 릴리즈 빌드

```bash
# APK (직접 배포 / 테스트용)
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# AAB (Play Store 배포용, 권장)
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

### 1.3 빌드 산출물 위치

| 파일 | 경로 | 용도 |
|------|------|------|
| APK | `build/app/outputs/flutter-apk/app-release.apk` | 직접 설치/테스트 |
| AAB | `build/app/outputs/bundle/release/app-release.aab` | Play Store 업로드 |

---

## 2. iOS 빌드 (클라우드)

> Windows에서는 iOS 빌드가 불가능합니다. 아래 클라우드 서비스를 활용합니다.

### 방법 A: Codemagic (추천)

#### 초기 설정

1. [codemagic.io](https://codemagic.io) 회원가입 (GitHub 연동)
2. 프로젝트 추가 → `KoreaWith` 리포지토리 선택
3. **Settings** → **Code signing** → **iOS**:
   - Apple Developer 계정 연결 (자동 프로비저닝)
   - 또는 수동으로 `.p12` + `.mobileprovision` 업로드
4. **Build** 클릭 → iOS IPA 생성 → TestFlight 자동 배포

#### 필요 계정

| 계정 | 용도 | 비용 |
|------|------|------|
| Apple Developer Program | 앱 서명 & App Store 배포 | $99/년 |
| Codemagic | 클라우드 빌드 | 무료 500분/월 |

#### 빌드 트리거

- `main` 브랜치에 push → 자동 빌드
- `codemagic.yaml` 설정 기반

### 방법 B: GitHub Actions

- `.github/workflows/flutter_ci.yml` 에 설정 완료
- `macos-latest` runner 사용 (무료 티어 포함)
- Secrets에 인증서 등록 필요:
  - `P12_BASE64`: .p12 인증서 (base64 인코딩)
  - `P12_PASSWORD`: 인증서 비밀번호
  - `PROVISION_PROFILE_BASE64`: 프로비저닝 프로파일
  - `KEYCHAIN_PASSWORD`: 임시 키체인 비밀번호

---

## 3. CI/CD 파이프라인 흐름

```
개발자 (Windows)
    │
    ├── git push develop ──→ GitHub Actions: 테스트 & 분석만
    │
    └── git push main ────→ GitHub Actions:
                              ├── 테스트 & 분석
                              ├── Android APK/AAB 빌드
                              └── iOS 빌드 (no-codesign 또는 서명)

                           Codemagic (대안):
                              ├── Android AAB → Play Store (internal)
                              └── iOS IPA → TestFlight
```

---

## 4. Play Store 배포 체크리스트

- [ ] Google Play Console 계정 생성 ($25 일회성)
- [ ] 앱 정보 입력 (제목, 설명, 스크린샷, 아이콘)
- [ ] 개인정보 처리방침 URL 등록
- [ ] 콘텐츠 등급 설문 완료
- [ ] 타겟 연령층 설정
- [ ] AAB 파일 업로드 → Internal Testing → Closed Testing → Production

## 5. App Store 배포 체크리스트

- [ ] Apple Developer Program 가입 ($99/년)
- [ ] App Store Connect에서 앱 생성
- [ ] 앱 정보 입력 (제목, 설명, 스크린샷, 아이콘)
- [ ] 개인정보 처리방침 URL 등록
- [ ] 앱 심사 가이드라인 확인
- [ ] IPA → TestFlight → 심사 제출 → 출시

---

## 6. 환경별 설정 요약

| 환경 | Android | iOS |
|------|---------|-----|
| **개발** | `flutter run` (에뮬레이터) | 불가 (Mac 없이) |
| **테스트** | `flutter build apk --debug` | Codemagic TestFlight |
| **스테이징** | `flutter build apk --release` | Codemagic TestFlight |
| **프로덕션** | `flutter build appbundle --release` → Play Store | Codemagic → App Store |
