# Architecture Overview

이 문서는 `domodachi`의 현재 애플리케이션 구조와 레이어 책임을 설명합니다.

## 최상위 구조

```text
apps/mobile/
  lib/       # 앱 조립, 화면 엔트리, 앱 전용 구성
packages/    # 기능/인프라 패키지
docs/        # 프로젝트 문서
supabase/    # 백엔드 설정과 migration
```

모바일 앱 셸은 `apps/mobile` 아래에 두고, 재사용 가능한 기능과 인프라는 `packages/` 아래에 둡니다.

현재 주요 feature:

- `auth`
- `chat`
- `friend`
- `home`
- `settings`

## 레이어 의존 방향

프로젝트 기본 규칙은 아래 방향을 유지하는 것입니다.

```text
presentation -> domain/use_case -> domain/repository -> data -> core/external
```

핵심 원칙:

- `presentation`은 data source를 직접 의존하지 않습니다.
- `domain`은 Flutter UI 패키지를 의존하지 않습니다.
- 외부 SDK 예외는 data layer에서 프로젝트 예외로 변환한 뒤 repository가 domain failure로 매핑합니다.

## 앱 조립 지점

- 앱 시작: [main.dart](../../apps/mobile/lib/main.dart)
- 앱 루트 위젯: [app.dart](../../apps/mobile/lib/app/app.dart)
- 라우터: [app_router.dart](../../apps/mobile/lib/app/router/app_router.dart)
- DI 초기화: [injection.dart](../../apps/mobile/lib/core/di/injection.dart)
- DI 모듈 등록: [register_module.dart](../../apps/mobile/lib/core/di/register_module.dart)

현재 앱 부팅 순서는 다음과 같습니다.

1. Supabase 초기화
2. DI 컨테이너 구성
3. `AuthSessionCubit`과 `ThemeModeCubit` 주입
4. `MaterialApp.router` 실행

## 상태관리

상태관리는 주로 `flutter_bloc` 기반입니다.

- 전역 세션 상태: `AuthSessionCubit`
- 화면 단위 요청 상태: feature별 `Cubit`
- 리스트, 실시간 스트림, 복합 흐름: feature별 `Bloc`

프로젝트 규칙상 같은 책임에 `Cubit`과 `Bloc`를 혼용하지 않는 편을 우선합니다.

## 라우팅

라우팅은 `go_router`를 사용하며 앱 전역 정책은 [app_router.dart](../../apps/mobile/lib/app/router/app_router.dart)에 모읍니다.

현재 핵심 정책:

- 인증 상태를 기준으로 접근 가능한 영역을 분기합니다.
- `unknown` 상태에서는 `splash`로 보냅니다.
- 비로그인 상태에서는 auth area만 허용합니다.
- 프로필 미완료 상태에서는 `profileSetup`만 허용합니다.
- 로그인 완료 상태에서는 auth area 접근을 홈으로 되돌립니다.

경로 상수는 [app_route_path.dart](../../apps/mobile/lib/app/router/app_route_path.dart)에 둡니다.

## Feature facade 패턴

이 프로젝트는 feature package 단위 facade를 둡니다.

- 인증: [AuthUseCases](../../packages/feature_auth/lib/domain/use_case/auth_use_cases.dart)
- 그룹채팅: [GroupChatUseCases](../../packages/feature_group_chat/lib/group_chat/domain/use_case/group_chat_use_cases.dart)
- 개인채팅: [PrivateChatUseCases](../../packages/feature_private_chat/lib/private_chat/domain/use_case/private_chat_use_cases.dart)
- 친구: [FriendUseCases](../../packages/feature_friend/lib/domain/use_case/friend_use_cases.dart)

의도는 다음과 같습니다.

- presentation이 개별 use case 클래스에 과도하게 결합되지 않게 합니다.
- DI 등록 대상을 줄여 feature 진입점을 명확하게 유지합니다.
- 기능별 공개 API를 한 파일에서 파악할 수 있게 합니다.

특히 인증 기능은 presentation이 `AuthRepository`가 아니라 `AuthUseCases`를 통해 동작하도록 유지합니다.

## Data layer 원칙

data source는 SDK 호출 흐름에 집중합니다.

- Supabase 접근은 data source 내부에 둡니다.
- Supabase 타입은 data source 경계 안에서만 사용합니다.
- 공유 helper 로직은 `...data_source_handler.dart` mixin으로 분리합니다.
- repository는 data model을 domain entity로 매핑하고 domain 타입만 노출합니다.

## 테마와 공통 UI

- 테마 조립: [app_theme.dart](../../packages/app_ui/lib/theme/app_theme.dart)
- 색상 체계: [app_color_scheme.dart](../../packages/app_ui/lib/theme/app_color_scheme.dart)
- 팔레트: [app_palette.dart](../../packages/app_ui/lib/theme/app_palette.dart)
- 타이포그래피: [app_typography.dart](../../packages/app_ui/lib/theme/app_typography.dart)

UI에서 임의 색상 상수보다 테마의 의미 기반 색상을 우선합니다.

## 추가 참고 문서

- 인증 상세: [Auth Feature](../../apps/mobile/lib/features/auth/README.md)
- 채팅 상세: [Chat Feature](../../apps/mobile/lib/features/chat/README.md)
- 친구 상세: [Friend Feature](../../apps/mobile/lib/features/friend/README.md)
