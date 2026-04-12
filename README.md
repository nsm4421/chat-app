# domodachi

`domodachi`는 Flutter와 Supabase를 기반으로 만든 모바일 우선 모의 코인 투자 앱입니다.
현재 저장소는 앱, 기능 패키지, 문서, Supabase 설정을 분리한 workspace 구조로 관리합니다.

## 핵심 스택

- Flutter
- Supabase
- `flutter_bloc`
- `go_router`
- `get_it` + `injectable`
- `Hive CE` + `SharedPreferences`

모바일 앱 의존성과 버전은 [pubspec.yaml](./apps/mobile/pubspec.yaml)을 기준으로 확인합니다.

## 프로젝트 구조

```text
apps/
  android/
packages/
docs/
supabase/
```

## 빠른 시작

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

환경 변수와 상세 실행 절차는 [docs/getting-started.md](./docs/getting-started.md)를 참고합니다.

## 문서 인덱스

- [문서 개요](./docs/README.md)
- [Getting Started](./docs/getting-started.md)
- [Architecture Overview](./docs/architecture/overview.md)
- [Testing Guide](./docs/testing.md)
- [Supabase Overview](./docs/supabase/overview.md)

## 기획 문서

- [Product Planning](./docs/planning/README.md)
- [Product Overview](./docs/planning/product-overview.md)
- [Identity Policy](./docs/planning/identity-policy.md)
- [User Flows](./docs/planning/user-flows.md)
- [Roadmap](./docs/planning/roadmap.md)

## Feature 문서

- [Auth Feature](./apps/mobile/lib/features/auth/README.md)

## 자주 쓰는 명령어

```bash
cd apps/mobile
flutter analyze
flutter test
flutter test test/features/auth
dart run build_runner build --delete-conflicting-outputs
```
