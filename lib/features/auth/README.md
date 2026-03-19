# Auth Feature

이 디렉터리는 `domodachi`의 인증 기능을 담당합니다.

## 현재 구현 범위

- 이메일/비밀번호 회원가입
- 이메일/비밀번호 로그인
- 로그아웃
- 계정 삭제
- 프로필 초기 설정
- 인증 상태에 따른 라우팅 분기

## 레이어 구성

### `data`

- `AuthDataSource`
  - Supabase SDK와 직접 통신합니다.
- `SupabaseAuthDataSourceImpl`
  - 로그인, 회원가입, 로그아웃, 계정 삭제, 프로필 저장을 처리합니다.
- `AuthUserModel`
  - data layer에서 사용하는 인증 사용자 모델입니다.
- `AuthRepositoryImpl`
  - data layer 예외를 domain failure로 변환하고 domain entity로 매핑합니다.

### `domain`

- `AuthRepository`
  - 인증 기능의 domain 인터페이스입니다.
- `AuthUser`
  - presentation/domain에서 사용하는 인증 사용자 엔티티입니다.
- `AuthUseCases`
  - 인증 관련 use case facade입니다.
- `AuthFailure`
  - 인증 기능에서 사용하는 domain failure입니다.

### `presentation`

- `AuthSessionCubit`
  - 전역 인증 세션 상태를 관리합니다.
- `SignInCubit`, `SignUpCubit`, `ProfileSetupCubit`, `PasswordResetCubit`, `DeleteAccountCubit`
  - 화면별 요청 상태를 관리합니다.
- `pages/`
  - 인증 진입, 로그인, 회원가입, 프로필 설정, 비밀번호 재설정 화면이 있습니다.
- `widgets/`
  - 인증 화면 공용 scaffold, password field, request listener 등을 둡니다.

## 현재 인증 흐름

1. 앱 시작 시 현재 세션을 확인합니다.
2. 세션이 없으면 인증 화면으로 이동합니다.
3. 세션이 있으면 프로필 완료 여부를 확인합니다.
4. 프로필이 미완료면 프로필 설정 화면으로 이동합니다.
5. 프로필이 완료되면 홈 화면으로 이동합니다.

## Supabase 스키마와 현재 연결 상태

현재 Supabase 쪽에는 아래 스키마가 준비되어 있습니다.

- `public.profiles`
  - `display_name`, `username`, `avatar_url`, `bio`, `onboarding_completed`
- `public.user_account_state`
  - `is_dormant`, `is_banned`, `last_seen_at`

하지만 현재 앱의 인증 기능은 `public.profiles`를 직접 읽지 않습니다.

- 현재 사용자 정보는 `auth.users`와 `user_metadata` 기준으로 읽습니다.
- 프로필 완료 여부도 `user_metadata.display_name`, `user_metadata.profile_completed` 기준으로 판단합니다.
- 프로필 저장도 현재는 `auth.updateUser(...data...)`로 metadata만 갱신합니다.
- 로그인 직후 `touch_current_user_account_state()` RPC를 호출해서 `last_seen_at`만 동기화합니다.

즉, 현재 기준의 사실상 source of truth는 `public.profiles`가 아니라 `auth.users.user_metadata`입니다.

## 구현 메모

- `profile_field_rules.dart`의 제약은 DB schema와 맞춰 두었습니다.
  - `display_name`: 2~30자
  - `username`: 소문자/숫자/밑줄, 3~20자
  - `bio`: 최대 160자
- 다만 `username`, `bio`, `avatar_url`, `onboarding_completed`는 아직 앱 모델과 엔티티에 반영되지 않았습니다.
- 추후 프로필 기능을 확장할 때는
  - `public.profiles`를 단일 source of truth로 쓸지
  - 지금처럼 `auth.users.user_metadata`를 계속 쓸지
  먼저 결정한 뒤 한쪽으로 정리하는 것이 좋습니다.
