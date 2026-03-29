# Getting Started

이 문서는 처음 저장소를 받은 사람이 앱을 실행하고 기본 검증까지 마치는 데 필요한 절차를 정리합니다.

## 준비물

- Flutter SDK
- Dart SDK
- Xcode 또는 Android Studio 중 개발 대상 플랫폼에 맞는 도구
- Supabase 프로젝트 또는 로컬 Supabase 환경

SDK 상세 버전은 [pubspec.yaml](../apps/mobile/pubspec.yaml)의 `environment`와 의존성 선언을 기준으로 확인합니다.

## 첫 실행 순서

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## 환경 변수

앱은 [app_env_selector.dart](../apps/mobile/lib/core/env/app_env_selector.dart)에서 플랫폼별 앱 환경을 선택합니다.
로컬 환경 파일은 [apps/mobile/.env.local](../apps/mobile/.env.local)에 둡니다.

필수 값:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

앱 시작 시 [main.dart](../apps/mobile/lib/main.dart)에서 아래 순서로 초기화합니다.

1. Flutter 바인딩 초기화
2. Supabase 초기화
3. DI 컨테이너 구성
4. 앱 실행

## codegen이 필요한 경우

아래 항목을 바꾸면 codegen을 다시 실행합니다.

- `freezed`
- `json_serializable`
- `injectable`
- `envied`

실행 명령:

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

생성 파일인 `*.freezed.dart`, `*.g.dart`, `*.config.dart`는 직접 수정하지 않습니다.

## 로컬 실행 팁

- 의존성 주입은 [injection.dart](../apps/mobile/lib/core/di/injection.dart)와 [register_module.dart](../apps/mobile/lib/core/di/register_module.dart)에서 구성합니다.
- `SharedPreferences`와 `Hive`는 DI 초기화 과정에서 선행 준비됩니다.
- Android emulator에서 로컬 Supabase를 사용할 때는 환경 변수의 URL 호스트를 에뮬레이터에서 접근 가능한 값으로 맞춰야 합니다.

## 최소 검증 절차

앱이 켜지지 않거나 설정이 꼬였는지 빠르게 확인할 때는 아래 순서가 가장 효율적입니다.

```bash
cd apps/mobile
flutter analyze
flutter test
flutter run
```

## 다음에 읽을 문서

- 구조와 책임 분리는 [architecture/overview.md](./architecture/overview.md)
- 테스트 기준은 [testing.md](./testing.md)
- 백엔드 구조는 [supabase/overview.md](./supabase/overview.md)
