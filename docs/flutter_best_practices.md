# Flutter 베스트 프랙티스 2025-2026 종합 가이드

> 이 문서는 2025-2026년 기준 Flutter 앱 개발의 모범 사례를 종합적으로 정리한 실무 가이드입니다.

---

## 목차

1. [프로젝트 구조](#1-프로젝트-구조-project-structure)
2. [상태 관리](#2-상태-관리-state-management)
3. [아키텍처 패턴](#3-아키텍처-패턴)
4. [코드 스타일 및 린팅](#4-코드-스타일-및-린팅)
5. [네비게이션](#5-네비게이션)
6. [의존성 주입](#6-의존성-주입)
7. [네트워킹](#7-네트워킹)
8. [로컬 저장소](#8-로컬-저장소)
9. [테스팅](#9-테스팅)
10. [성능 최적화](#10-성능-최적화)
11. [보안](#11-보안)
12. [CI/CD](#12-cicd)
13. [국제화 (i18n)](#13-국제화-i18n)
14. [추천 패키지 목록](#14-추천-패키지-목록)

---

## 1. 프로젝트 구조 (Project Structure)

### Feature-first vs Layer-first

| 구분 | Feature-first | Layer-first |
|------|--------------|-------------|
| **구조** | 기능별로 폴더 분리 | 계층별로 폴더 분리 |
| **적합한 규모** | 중~대규모 프로젝트 | 소규모 프로젝트 |
| **장점** | 기능별 독립 개발, 모듈화 용이 | 간단하고 직관적 |
| **단점** | 초기 설정 복잡 | 기능 추가 시 여러 폴더 수정 필요 |

**2025-2026년 기준 Feature-first 구조가 대규모 프로젝트의 표준**

### 권장 Feature-first 폴더 구조

```
lib/
├── app/                          # 앱 진입점, 라우팅 설정
│   ├── app.dart
│   └── routes.dart
├── core/                         # 전역 공통 요소
│   ├── constants/                # 상수 정의
│   ├── theme/                    # 테마 데이터
│   ├── utils/                    # 유틸리티 함수
│   ├── enums/                    # 공통 열거형
│   └── errors/                   # 에러 클래스
├── shared/                       # 공유 컴포넌트
│   ├── widgets/                  # 공통 위젯
│   ├── models/                   # 공통 모델
│   └── services/                 # 공통 서비스
├── features/                     # 기능별 모듈
│   ├── auth/
│   │   ├── data/                 # API, Repository 구현, DTO
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/               # 비즈니스 로직, UseCase, Entity
│   │   │   ├── entities/
│   │   │   ├── repositories/     # Repository 인터페이스
│   │   │   └── usecases/
│   │   └── presentation/         # UI, 상태 관리
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/        # 또는 blocs/
│   ├── home/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── settings/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── l10n/                         # 국제화 파일
│   ├── app_ko.arb
│   └── app_en.arb
└── main.dart
```

### 핵심 원칙

- 각 feature 폴더에 `index.dart`를 만들어 re-export 처리
- 공통 위젯과 서비스는 `shared/` 폴더에 배치
- feature 간 의존성은 최소화하고, 필요한 경우 `shared/`를 통해 공유
- `core/`에는 테마, 상수, 전역 유틸리티만 배치

---

## 2. 상태 관리 (State Management)

### 2025-2026 상태 관리 솔루션 비교

| 항목 | Riverpod 3.0 | BLoC 9.0 | Provider | Signals 6.0 |
|------|-------------|----------|----------|-------------|
| **적합한 규모** | 중~대규모 | 대규모/엔터프라이즈 | 소~중규모 | 성능 중심 앱 |
| **러닝 커브** | 중간 | 높음 | 낮음 | 중간 |
| **보일러플레이트** | 최소 | 많음 | 적음 | 최소 |
| **타입 안전성** | 컴파일 타임 | 런타임 | 런타임 | 컴파일 타임 |
| **테스트 용이성** | 매우 좋음 | 매우 좋음 | 좋음 | 좋음 |
| **BuildContext 의존** | 없음 | 있음 | 있음 | 없음 |

### 권장 사항

**대부분의 프로젝트: Riverpod 3.0** (de facto 표준)

- 컴파일 타임 안전성
- 내장 오프라인 퍼시스턴스
- 최소한의 보일러플레이트
- BuildContext 불필요

**엔터프라이즈/규제 산업: BLoC 9.0**

- 이벤트 기반 감사 추적(Audit Trail)
- 엄격한 관심사 분리
- 금융, 의료 앱에 적합

### 하이브리드 전략 (권장)

```dart
// 로컬 상태: StatefulWidget 또는 ValueNotifier 사용
// - 모달 열림/닫힘, 텍스트 필드 값 등 일시적 UI 상태

// 글로벌 상태: Riverpod 사용
// - 사용자 인증, 설정, API 데이터 등

// Riverpod 3.0 예시
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    return ref.watch(authRepositoryProvider).currentUser;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signIn(email, password),
    );
  }
}

// UI에서 사용
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    return authState.when(
      data: (user) => user != null ? const HomePage() : const LoginForm(),
      loading: () => const CircularProgressIndicator(),
      error: (e, st) => ErrorWidget(e.toString()),
    );
  }
}
```

### 선택 가이드

- **10K 라인 이하 소규모 앱** → Provider / ChangeNotifier
- **중규모 앱 (스타트업, SaaS)** → Riverpod 3.0
- **대규모 엔터프라이즈 앱** → BLoC 9.0
- **성능 크리티컬 앱** → Signals 6.0

---

## 3. 아키텍처 패턴

### Clean Architecture + MVVM (권장 조합)

**Clean Architecture + MVVM + Feature-first 구조**의 조합이 가장 널리 채택

```
┌─────────────────────────────────────────────┐
│              Presentation Layer             │
│   (Pages, Widgets, ViewModels/Providers)    │
├─────────────────────────────────────────────┤
│               Domain Layer                  │
│     (Entities, UseCases, Repository         │
│              Interfaces)                    │
├─────────────────────────────────────────────┤
│                Data Layer                   │
│   (Repository Impl, DataSources,            │
│          Models/DTOs)                       │
└─────────────────────────────────────────────┘
```

### 각 계층의 역할

**Presentation Layer (프레젠테이션 계층)**
- UI 렌더링만 담당 (View는 "dumb"하게 유지)
- ViewModel/Provider가 비즈니스 로직 호출
- StateNotifier 또는 ChangeNotifier로 반응형 상태 관리

**Domain Layer (도메인 계층)**
- 비즈니스 로직의 핵심
- UseCase: 하나의 비즈니스 동작을 캡슐화
- Repository Interface: 데이터 계층과의 계약 정의
- Entity: 순수 비즈니스 객체

**Data Layer (데이터 계층)**
- Repository 구현체
- Remote/Local DataSource
- DTO (Data Transfer Object): API 응답 매핑

### Repository Pattern 구현 예시

```dart
// Domain Layer - Repository Interface
abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String id);
  Future<Either<Failure, List<User>>> getUsers();
}

// Data Layer - Repository Implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getUser(id);
        await localDataSource.cacheUser(remoteUser);
        return Right(remoteUser.toDomain());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localUser = await localDataSource.getCachedUser(id);
        return Right(localUser.toDomain());
      } on CacheException {
        return Left(CacheFailure('캐시된 데이터가 없습니다'));
      }
    }
  }
}

// Domain Layer - UseCase
class GetUserUseCase {
  final UserRepository repository;
  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> call(String id) {
    return repository.getUser(id);
  }
}
```

### 핵심 원칙

- **의존성 규칙**: 안쪽 계층은 바깥 계층을 알지 못함 (Domain → Data 의존 금지)
- **불변성(Immutability)**: 상태 객체는 불변으로 관리
- **단일 책임 원칙**: 각 UseCase는 하나의 비즈니스 동작만 수행

---

## 4. 코드 스타일 및 린팅

### very_good_analysis 사용 (권장)

```yaml
# pubspec.yaml
dev_dependencies:
  very_good_analysis: ^7.0.0

# analysis_options.yaml
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
    sort_pub_dependencies: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"
    - "lib/generated/**"
  errors:
    invalid_annotation_target: ignore
```

### DCM (Dart Code Metrics) 추가 활용

```yaml
dart_code_metrics:
  metrics:
    cyclomatic-complexity: 20
    number-of-parameters: 4
    maximum-nesting-level: 5
  rules:
    - avoid-unused-parameters
    - prefer-trailing-comma
    - member-ordering:
        order:
          - constructors
          - public-fields
          - private-fields
          - public-methods
          - private-methods
```

### 코드 컨벤션 핵심 규칙

```dart
// ✅ Good: trailing comma 사용 (자동 포맷팅 최적화)
const Widget myWidget = Padding(
  padding: EdgeInsets.all(16.0),
  child: Text('Hello'),
);

// ✅ Good: 상수에는 const 사용
const kDefaultPadding = 16.0;

// ✅ Good: 파일명은 snake_case
// user_profile_page.dart

// ✅ Good: 클래스명은 PascalCase, 변수/함수는 camelCase
class UserProfilePage extends StatelessWidget { ... }

// ✅ Good: private 변수는 _ 접두사
final String _userId;
```

---

## 5. 네비게이션

### GoRouter vs auto_route 비교

| 항목 | GoRouter | auto_route |
|------|---------|------------|
| **상태** | 유지보수 모드 (안정적) | 활발한 개발 |
| **방식** | 선언적 라우팅 | 코드 생성 기반 |
| **Deep Link** | 내장 지원 | 내장 지원 |
| **타입 안전성** | 수동 설정 | 자동 (코드 생성) |
| **Flutter 공식** | 공식 추천 | 커뮤니티 |

### GoRouter 설정 예시

```dart
final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  redirect: (context, state) {
    final isLoggedIn = /* 인증 상태 확인 */;
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) return '/login';
    if (isLoggedIn && isLoginRoute) return '/';
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomePage(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return DetailPage(id: id);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
);
```

---

## 6. 의존성 주입

### get_it + injectable 조합

```dart
// injection.dart
final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

### Riverpod을 DI로 활용 (Riverpod 사용 시 권장)

```dart
@riverpod
Dio dio(Ref ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.example.com',
    connectTimeout: const Duration(seconds: 10),
  ))..interceptors.add(
    ref.watch(authInterceptorProvider),
  );
}

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(
    remoteDataSource: UserRemoteDataSource(ref.watch(dioProvider)),
    localDataSource: ref.watch(userLocalDataSourceProvider),
  );
}
```

### 선택 가이드

| 상황 | 권장 |
|------|-----|
| Riverpod 사용 중 | Riverpod 자체 DI 활용 |
| BLoC 사용 중 | get_it + injectable |
| 대규모 엔터프라이즈 | get_it + injectable |
| 소규모 프로젝트 | 생성자 주입 (Constructor Injection) |

---

## 7. 네트워킹

### Dio + Retrofit 조합 (권장)

```dart
// Retrofit API 인터페이스
@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @GET('/users/{id}')
  Future<UserResponse> getUser(@Path('id') String id);

  @GET('/users')
  Future<List<UserResponse>> getUsers(
    @Query('page') int page,
    @Query('limit') int limit,
  );

  @POST('/users')
  Future<UserResponse> createUser(@Body() CreateUserRequest request);

  @DELETE('/users/{id}')
  Future<void> deleteUser(@Path('id') String id);
}
```

### Dio 인터셉터 설정

```dart
class DioClient {
  static Dio createDio({
    required String baseUrl,
    required TokenStorage tokenStorage,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    dio.interceptors.add(AuthInterceptor(tokenStorage: tokenStorage, dio: dio));
    dio.interceptors.add(RetryInterceptor(dio: dio, retries: 3));

    return dio;
  }
}
```

### 통합 에러 핸들링

```dart
sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class ServerFailure extends AppFailure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

class ApiErrorHandler {
  static AppFailure handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure('요청 시간이 초과되었습니다');
      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);
      case DioExceptionType.connectionError:
        return const NetworkFailure('네트워크 연결을 확인해주세요');
      default:
        return const ServerFailure('알 수 없는 오류가 발생했습니다');
    }
  }
}
```

---

## 8. 로컬 저장소

### 솔루션 비교

| 항목 | SharedPreferences | Hive | Drift (SQLite) |
|------|-------------------|------|----------------|
| **용도** | 단순 설정값 | 경량 객체 저장 | 관계형 데이터 |
| **성능** | 느림 | 매우 빠름 | 빠름 |
| **타입 안전성** | 없음 | 있음 | 매우 강함 |
| **암호화** | 없음 | 내장 지원 | 플러그인 필요 |
| **적합한 용도** | 앱 설정, 플래그 | 캐시, 세션 | 복잡한 쿼리 |

### 권장: 기본 선택은 Drift, 단순 설정은 SharedPreferences

### Drift 사용 예시

```dart
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  Future<List<User>> getAllUsers() => select(users).get();
  Stream<List<User>> watchAllUsers() => select(users).watch();
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);
}
```

---

## 9. 테스팅

### 테스트 피라미드 전략

```
         /\
        /  \          Integration Tests (소수)
       /    \         - 전체 사용자 플로우 검증
      /------\
     /        \       Widget Tests (중간)
    /          \      - 개별 위젯 동작 검증
   /------------\
  /              \    Unit Tests (다수)
 /                \   - 비즈니스 로직, Repository, UseCase
/------------------\
```

### Unit Test

```dart
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late GetUserUseCase useCase;
  late MockUserRepository mockRepository;

  setUp(() {
    mockRepository = MockUserRepository();
    useCase = GetUserUseCase(mockRepository);
  });

  group('GetUserUseCase', () {
    const tUserId = '123';
    final tUser = User(id: tUserId, name: '홍길동', email: 'hong@test.com');

    test('성공 시 User 객체를 반환해야 한다', () async {
      when(() => mockRepository.getUser(tUserId))
          .thenAnswer((_) async => Right(tUser));

      final result = await useCase(tUserId);

      expect(result, Right(tUser));
      verify(() => mockRepository.getUser(tUserId)).called(1);
    });
  });
}
```

### Widget Test

```dart
testWidgets('LoginPage - 로그인 버튼 클릭', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => MockAuthNotifier()),
      ],
      child: const MaterialApp(home: LoginPage()),
    ),
  );

  await tester.enterText(find.byKey(const Key('emailField')), 'test@test.com');
  await tester.enterText(find.byKey(const Key('passwordField')), 'password123');
  await tester.tap(find.byKey(const Key('loginButton')));
  await tester.pumpAndSettle();

  expect(find.text('로그인 성공'), findsOneWidget);
});
```

### 테스팅 도구

- **Mocktail**: Mock 객체 생성 (코드 생성 불필요)
- **Bloc Test**: BLoC 전용 테스트 유틸리티
- **Golden Tests**: 스크린샷 기반 UI 회귀 테스트

---

## 10. 성능 최적화

### const 위젯 활용 (리빌드 최대 70% 감소)

```dart
// ✅ Good
const Column(
  children: [
    SizedBox(height: 16),
    Icon(Icons.star, color: Colors.amber),
    Text('Hello World'),
  ],
);

// ❌ Bad: const 누락
Column(
  children: [
    SizedBox(height: 16),
    Icon(Icons.star, color: Colors.amber),
    Text('Hello World'),
  ],
);
```

### Lazy Loading

```dart
// ✅ Good: ListView.builder
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ListTile(title: Text(items[index].name));
  },
);

// ❌ Bad: 전체 리스트 한 번에 렌더링
ListView(
  children: items.map((item) => ListTile(title: Text(item.name))).toList(),
);
```

### 이미지 캐싱

```dart
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 300,
  maxWidthDiskCache: 600,
);
```

### 추가 최적화

```dart
// RepaintBoundary: 불필요한 repaint 방지
RepaintBoundary(child: ComplexAnimatedWidget())

// 무거운 연산은 compute/Isolate 사용
final result = await compute(parseJsonData, rawData);

// 이미지 리사이징
Image.asset('assets/large_image.png', cacheWidth: 300, cacheHeight: 300);
```

---

## 11. 보안

### API Key 관리

**가장 안전한 방법: 서버 사이드 프록시**

```
Flutter App  →  Backend (Cloud Function)  →  외부 API
               (API Key는 서버에만 존재)
```

**차선책: ENVied 패키지**

```dart
// .env (git에 절대 커밋하지 않음)
API_KEY=your_secret_key_here

// env.dart
@Envied(path: '.env', obfuscate: true)
abstract class Env {
  @EnviedField(varName: 'API_KEY')
  static const String apiKey = _Env.apiKey;
}
```

### flutter_secure_storage

```dart
class SecureTokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<void> saveToken(String token) =>
      _storage.write(key: 'access_token', value: token);

  Future<String?> getToken() =>
      _storage.read(key: 'access_token');

  Future<void> deleteToken() =>
      _storage.delete(key: 'access_token');
}
```

### 빌드 시 난독화

```bash
flutter build apk --obfuscate --split-debug-info=build/debug-info
flutter build ipa --obfuscate --split-debug-info=build/debug-info
```

### 보안 체크리스트

- [ ] API Key를 소스 코드에 하드코딩하지 않기
- [ ] `.env` 파일을 `.gitignore`에 추가
- [ ] 민감 데이터는 `flutter_secure_storage` 사용
- [ ] 릴리즈 빌드 시 `--obfuscate` 플래그 적용
- [ ] HTTPS 통신 강제
- [ ] 디버그 모드에서만 로깅 활성화

---

## 12. CI/CD

### GitHub Actions 설정

```yaml
# .github/workflows/flutter_ci.yml
name: Flutter CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.x'
          channel: stable
      - run: flutter pub get
      - run: flutter analyze --fatal-infos
      - run: flutter test --coverage

  build-android:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.x'
          channel: stable
      - run: flutter build apk --release --obfuscate --split-debug-info=build/debug-info
      - uses: actions/upload-artifact@v4
        with:
          name: release-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-ios:
    needs: test
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.x'
          channel: stable
      - run: flutter build ipa --release --export-method=app-store
```

### Codemagic (Flutter 특화 CI/CD)

```yaml
# codemagic.yaml
workflows:
  flutter-app:
    name: Flutter App
    max_build_duration: 60
    instance_type: mac_mini_m2
    environment:
      flutter: stable
    scripts:
      - name: Get dependencies
        script: flutter pub get
      - name: Run tests
        script: flutter test
      - name: Build Android
        script: flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
      - name: Build iOS
        script: flutter build ipa --release
    artifacts:
      - build/**/outputs/**/*.aab
      - build/ios/ipa/*.ipa
```

### CI/CD 선택 가이드

| 항목 | GitHub Actions | Codemagic |
|------|---------------|-----------|
| **비용** | 무료 티어 있음 | 무료 500분/월 |
| **iOS 빌드** | macos-latest (느림) | M2 Mac Mini (빠름) |
| **설정 난이도** | 중간 | 낮음 (Flutter 특화) |
| **코드 사이닝** | 수동 설정 | 자동화 지원 |

---

## 13. 국제화 (i18n)

### Flutter 공식 l10n (권장)

```yaml
# pubspec.yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any

flutter:
  generate: true

# l10n.yaml
arb-dir: lib/l10n
template-arb-file: app_ko.arb
output-localization-file: app_localizations.dart
preferred-supported-locales: [ko]
```

```json
// lib/l10n/app_ko.arb
{
  "@@locale": "ko",
  "appTitle": "나의 앱",
  "welcomeMessage": "안녕하세요, {name}님!",
  "@welcomeMessage": {
    "placeholders": {
      "name": { "type": "String" }
    }
  },
  "itemCount": "{count, plural, =0{항목 없음} =1{1개 항목} other{{count}개 항목}}"
}
```

```dart
// 사용
Text(AppLocalizations.of(context)!.welcomeMessage('홍길동'));
```

---

## 14. 추천 패키지 목록

### 상태 관리
| 패키지 | 용도 |
|--------|------|
| `flutter_riverpod` | 반응형 상태 관리 (추천) |
| `riverpod_annotation` | Riverpod 코드 생성 |
| `flutter_bloc` | 이벤트 기반 상태 관리 |

### 네트워킹
| 패키지 | 용도 |
|--------|------|
| `dio` | HTTP 클라이언트 |
| `retrofit` | 타입 안전 API 클라이언트 생성 |
| `connectivity_plus` | 네트워크 상태 모니터링 |

### 코드 생성
| 패키지 | 용도 |
|--------|------|
| `freezed` | 불변 데이터 클래스 + Union Type |
| `json_serializable` | JSON 직렬화/역직렬화 |
| `build_runner` | 코드 생성 실행기 |

### UI / UX
| 패키지 | 용도 |
|--------|------|
| `cached_network_image` | 네트워크 이미지 캐싱 |
| `flutter_svg` | SVG 이미지 렌더링 |
| `shimmer` | 로딩 스켈레톤 효과 |
| `lottie` | JSON 기반 벡터 애니메이션 |
| `google_fonts` | Google Fonts 적용 |
| `flutter_screenutil` | 반응형 UI 크기 조정 |

### 로컬 저장소
| 패키지 | 용도 |
|--------|------|
| `drift` | 타입 안전 SQLite ORM |
| `hive_ce` | 경량 NoSQL 데이터베이스 |
| `shared_preferences` | 단순 Key-Value 저장 |
| `flutter_secure_storage` | 민감 데이터 암호화 저장 |

### 유틸리티
| 패키지 | 용도 |
|--------|------|
| `fpdart` | 함수형 프로그래밍 (Either, Option) |
| `intl` | 날짜/시간/통화 포맷팅 |
| `logger` | 구조화된 로깅 |
| `envied` | 환경 변수 관리 (난독화 지원) |
| `permission_handler` | 권한 요청 관리 |

### 테스팅
| 패키지 | 용도 |
|--------|------|
| `mocktail` | Mock 객체 생성 |
| `bloc_test` | BLoC 전용 테스트 |
| `golden_toolkit` | 스크린샷 회귀 테스트 |

### 코드 품질
| 패키지 | 용도 |
|--------|------|
| `very_good_analysis` | 엄격한 린트 규칙 |

---

## 프로젝트 시작 시 체크리스트

1. [ ] **Feature-first** 폴더 구조 설정
2. [ ] **very_good_analysis** 린트 규칙 적용
3. [ ] 상태 관리 선택 (대부분 **Riverpod 3.0**)
4. [ ] **GoRouter** 네비게이션 설정
5. [ ] **Dio + Retrofit** 네트워킹 계층 구축
6. [ ] **Drift** 또는 **Hive** 로컬 저장소 설정
7. [ ] **flutter_secure_storage**로 민감 데이터 관리
8. [ ] **freezed + json_serializable** 데이터 모델 생성
9. [ ] CI/CD 파이프라인 구성
10. [ ] 테스트 전략 수립 (Unit > Widget > Integration)
11. [ ] i18n 설정
12. [ ] `.gitignore`에 보안 관련 파일 추가
