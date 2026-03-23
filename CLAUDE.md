# KoreaWith (Jeong) - Project Guide

## Architecture: Hybrid Backend

### Flutter (client/) → Supabase 직접 연결
- 인증 (Google/Apple OAuth)
- DB CRUD (places, reviews, bookmarks, profiles)
- 실시간 데이터 (Realtime Channels)
- RLS 기반 보안

### Flutter (client/) → NestJS (server/) 호출
- 외부 API 크롤링/스크래핑이 필요한 경우
- Puppeteer 브라우저 자동화가 필요한 경우

### NestJS 서버 모듈 (server/)
| 모듈 | 역할 | 엔드포인트 |
|---|---|---|
| naver-map | 네이버 지도 검색, 지오코딩 (Puppeteer로 토큰/검색) | `/api/naver-map/*` |
| diningcode | 다이닝코드 맛집 검색/상세 | `/api/diningcode/*` |
| proxy | HTTP 클라이언트 + anti-bot 스크래핑 (got-scraping) | 내부 서비스 |

## Tech Stack
- **Client**: Flutter + Riverpod + GoRouter + Supabase SDK
- **Server**: NestJS + Puppeteer + got-scraping
- **DB**: Supabase (PostgreSQL + RLS)
- **Push**: Firebase Cloud Messaging (FCM)

## Key Patterns
- `_useSupabase` 토글: mock 데이터 ↔ Supabase 전환 (place_provider, review_provider)
- Repository 패턴: 데이터 소스 교체 용이
- AsyncValue 처리: FutureProvider → `.valueOrNull ?? []` 또는 `.when()`
