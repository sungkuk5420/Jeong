# Flutter 크로스 플랫폼 조사 (Android / iOS / Web)

> 조사일: 2026-03-09

## 결론 요약

**Flutter는 단일 코드베이스로 Android, iOS, Web 모두 빌드 가능하다.** (+ Windows, macOS, Linux도 지원)
Android/iOS는 프로덕션 수준으로 성숙하고, Web은 **앱 스타일(대시보드, 내부 툴, SaaS)** 에는 적합하지만 **SEO가 중요한 콘텐츠 사이트에는 부적합**하다.

---

## 플랫폼별 성숙도

| 플랫폼 | 성숙도 | 비고 |
|--------|--------|------|
| **Android** | ✅ 완전 성숙 | Flutter의 원래 타겟. Google 1st-class 지원 |
| **iOS** | ✅ 완전 성숙 | Cupertino 위젯으로 iOS 네이티브 룩 제공. Apple 업데이트 시 플러그인 지연 가능성 |
| **Web** | ⚠️ 성숙하지만 제약 있음 | 대시보드/SaaS MVP에 적합. SEO 근본적 한계. WebAssembly로 성능 개선 중 |

---

## 플랫폼별 장단점

### Android

| 장점 | 단점 |
|------|------|
| ARM 네이티브 컴파일 → 네이티브에 근접한 성능 | 순수 네이티브 대비 APK 크기 증가 (엔진 번들 포함) |
| Material Design 깊은 통합 | CPU/메모리/배터리 사용량 약간 높음 |
| Impeller 렌더링 엔진으로 부드러운 애니메이션 | |
| 첫 프레임 50ms 이하 렌더링 | |

### iOS

| 장점 | 단점 |
|------|------|
| 모든 iOS 기기에서 픽셀 퍼펙트 UI | Apple OS 업데이트 시 플러그인 지원 지연 가능 |
| Cupertino 위젯 라이브러리 제공 | 일부 플랫폼 API는 네이티브 플러그인/플랫폼 채널 필요 |
| 대부분의 경우 Swift 앱과 비교 가능한 성능 | Safari/WebKit 관련 엣지 케이스 |

### Web

| 장점 | 단점 |
|------|------|
| 같은 코드베이스로 웹 배포 가능 | **SEO 근본적 한계** (Canvas 렌더링, 시맨틱 HTML 없음) |
| WebAssembly로 2.3배 빠른 로딩 | 초기 JS 번들 사이즈 큼 |
| Hot reload 웹에서도 안정화 (Flutter 3.35~) | Lighthouse/Core Web Vitals 점수 낮음 |
| 대시보드/내부 툴/SaaS MVP에 적합 | 기본 URL이 해시(#) 기반 → 수동 설정 필요 |

---

## Flutter 전체 장단점

### 장점

- **단일 코드베이스** → 6개+ 플랫폼 지원, 개발 비용 ~25% 절감, 생산성 ~35% 향상
- **Hot Reload** → 코드 변경 즉시 반영, 빠른 개발 사이클
- **Impeller 렌더링 엔진** → Skia 대체, 빌드 시 셰이더 컴파일로 런타임 버벅임 제거
- **풍부한 위젯 라이브러리** → 높은 수준의 커스터마이징 가능
- **강력한 생태계** → pub.dev에 수만 개 패키지
- **Google 지원** → GitHub 별 166,000+, 크로스플랫폼 개발자 채택률 46%

### 단점

- **Dart 인력풀 작음** → JavaScript/Swift/Kotlin 대비 채용 어려움
- **앱 크기 증가** → 엔진과 프레임워크 번들 포함
- **웹 SEO 한계** → Canvas 기반 렌더링의 구조적 문제
- **3D/GPU 집약 앱에 부적합** → 네이티브가 여전히 우위
- **플랫폼 특화 기능** → 네이티브 코드 작성 필요한 경우 있음

---

## 경쟁 프레임워크 비교

### Flutter vs React Native

| 항목 | Flutter | React Native |
|------|---------|-------------|
| 언어 | Dart | JavaScript/TypeScript |
| 렌더링 | 자체 캔버스 (Impeller) | 네이티브 플랫폼 컴포넌트 |
| 성능 | 첫 프레임 빠름, 60/120Hz 여유 | 정상 상태에서 일관적 |
| UI 일관성 | 플랫폼 간 픽셀 퍼펙트 | 플랫폼 네이티브 룩 기본 |
| 웹 지원 | 내장 (SEO 제약) | React 통한 별도 지원 (성숙) |
| 커뮤니티 | 크고 성장 중 | 매우 큼, JS 생태계 활용 |
| 채용 | 어려움 (Dart) | 쉬움 (JS/React 개발자 풍부) |
| **추천 케이스** | 커스텀 UI, 디자인 일관성 중시 | JS/React 팀, 네이티브 느낌 중시 |

### Flutter vs 네이티브 개발

| 항목 | Flutter | Native (Swift/Kotlin) |
|------|---------|----------------------|
| 개발 속도 | 빠름 (단일 코드베이스) | 느림 (플랫폼별 코드베이스) |
| 성능 | 대부분 앱에서 네이티브 근접 | 최고 성능 |
| 플랫폼 API | 플러그인/채널 통해 접근 | 직접 접근 |
| 앱 크기 | 큼 | 작음 |
| 유지보수 비용 | 낮음 | 높음 (2개 코드베이스) |
| **추천 케이스** | 비즈니스 앱, MVP, 스타트업 | 성능 critical, 깊은 OS 통합 |

---

## 성능 수치 참고

| 항목 | 수치 |
|------|------|
| Android 프레임 렌더링 목표 | 60fps: 16ms 이하 / 120fps: 8ms 이하 |
| Web Wasm 페이지 로드 개선 | 기존 JS 대비 **2.3배 빠름** |
| 첫 프레임 렌더링 | 50ms 이하 (Android) |

---

## KoreaWith 프로젝트 관점 판단

| 고려사항 | 판단 |
|----------|------|
| Android + iOS 동시 지원 | ✅ Flutter 적합 |
| 웹도 함께 지원 | ⚠️ 앱 스타일이면 가능, SEO 필요하면 별도 웹 고려 |
| 팀 언어 역량 (Dart) | 학습 곡선 있지만 Dart는 진입장벽 낮음 |
| MVP 빠른 출시 | ✅ 단일 코드베이스로 속도 이점 |

---

## 참고 자료

- [Flutter Official - Multi-platform](https://flutter.dev/multi-platform)
- [Flutter vs React Native vs Native: 2025 Performance Benchmark](https://www.synergyboat.com/blog/flutter-vs-react-native-vs-native-performance-benchmark-2025)
- [Flutter vs React Native in 2026 - TechAhead](https://www.techaheadcorp.com/blog/flutter-vs-react-native-in-2026/)
- [Flutter Pros and Cons 2025 - Leancode](https://leancode.co/blog/flutter-pros-and-cons-summary)
- [Flutter Web FAQ - Official Docs](https://docs.flutter.dev/platform-integration/web/faq)
- [State of Flutter 2026](https://devnewsletter.com/p/state-of-flutter-2026/)
