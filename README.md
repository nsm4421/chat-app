# domodachi

`domodachi`는 Supabase 기반 인증 흐름을 포함한 Flutter 앱입니다.
현재 구조는 모바일 우선 앱으로 확장하기 쉽게 최소 단위로 정리되어 있습니다.

## 프로젝트 구조

```text
lib/
  app/
  core/
  features/
assets/
supabase/
test/
```

## 실행 방법

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## 테스트 실행 방법

전체 테스트 실행:

```bash
flutter test
```

인증 기능 테스트만 실행:

```bash
flutter test test/features/auth
```

## 현재 작성된 인증 테스트

인증 테스트는 아직 얇게 시작한 상태이며, 핵심 분기만 우선 검증합니다.

### Domain

- `test/features/auth/domain/auth_user_test.dart`
  - `AuthUser.isProfileComplete` 계산 규칙을 확인합니다.
  - `displayName`과 `profileCompleted`가 모두 있어야 프로필 완료로 처리되는지 검증합니다.

### Data

- `test/features/auth/data/auth_user_mapper_test.dart`
  - data model이 domain entity로 올바르게 변환되는지 확인합니다.
- `test/features/auth/data/auth_repository_error_handler_test.dart`
  - data layer 예외가 사용자용 `AuthFailure` 메시지로 잘 변환되는지 확인합니다.

### Presentation

- `test/features/auth/presentation/cubit/auth_session_cubit_test.dart`
  - 세션 없음, 프로필 미완료, 프로필 완료 상태를 올바르게 분기하는지 확인합니다.
  - auth 상태 스트림 변경에 따라 `unauthenticated`, `profileIncomplete`, `authenticated` 상태로 바뀌는지 검증합니다.
- `test/features/auth/presentation/cubit/sign_in_cubit_test.dart`
  - 로그인 요청 시 `loading -> success` 흐름이 나오는지 확인합니다.
  - 로그인 실패 시 `loading -> error` 흐름과 에러 메시지를 검증합니다.
- `test/features/auth/presentation/pages/sign_in_page_test.dart`
  - 로그인 화면에서 비어 있는 폼 제출 시 검증 메시지가 보이는지 확인합니다.
  - 유효한 입력이면 trim된 이메일로 실제 로그인 요청이 호출되는지 확인합니다.

### 테스트 지원 코드

- `test/features/auth/support/fake_auth_repository.dart`
  - 인증 관련 테스트에서 공통으로 사용하는 가짜 저장소입니다.
  - cubit과 page 테스트에서 외부 의존성 없이 인증 흐름만 빠르게 검증할 수 있게 해줍니다.

## 테스트 작성 원칙

현재 인증 기능 테스트는 다음 기준으로 유지합니다.

- 화면 전체를 무겁게 붙잡는 integration test만으로 가지 않습니다.
- 분기 로직은 cubit 단위에서 빠르게 검증합니다.
- 사용자 입력과 폼 검증은 widget test로 확인합니다.
- repository, datasource, 실제 Supabase 연동은 필요할 때만 더 깊게 확장합니다.

즉, 인증 테스트는 `적은 수의 unit/widget 테스트로 핵심 리스크를 먼저 막는 방식`을 기본으로 합니다.

## Supabase

`supabase/` 디렉터리는 로컬 Supabase 설정, 마이그레이션, 엣지 함수 용도로 사용합니다.

앱 시작 시 [bootstrap.dart](/Users/n/Desktop/pg/lib/core/bootstrap/bootstrap.dart)에서 Supabase를 초기화하고,
이후 `get_it` + `injectable`로 의존성을 등록합니다.

로컬 개발에서 `.env.local`의 `SUPABASE_URL`이 `127.0.0.1` 또는 `localhost`여도,
Android emulator를 사용할 때는 `.env.local`에 `http://10.0.2.2:54321`를 직접 넣어 사용합니다.
즉, `.env.local` 하나로 desktop, iOS simulator, Android emulator를 같이 대응합니다.
