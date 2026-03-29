# Testing Guide

이 문서는 `domodachi`에서 테스트를 어디까지, 어떤 경계에서 작성하는지 정리합니다.

## 기본 원칙

- 핵심 리스크를 가장 싼 테스트 경계에서 먼저 막습니다.
- feature의 공개 경계를 기준으로 테스트합니다.
- generated file은 직접 테스트하지 않습니다.
- SDK 내부 동작을 재검증하기보다 우리 코드의 분기와 매핑을 검증합니다.

## 레이어별 테스트 전략

### Domain

다음 내용을 우선 검증합니다.

- entity 규칙
- validation 규칙
- use case 분기
- failure 변환 이후의 domain 동작

예시:

- [auth_user_test.dart](../apps/mobile/test/features/auth/domain/auth_user_test.dart)
- [chat_room_invariant_use_case_test.dart](../apps/mobile/test/features/chat/domain/use_case/chat_room_invariant_use_case_test.dart)
- [friend_input_validator_test.dart](../apps/mobile/test/features/friend/domain/validation/friend_input_validator_test.dart)

### Data

다음 내용을 우선 검증합니다.

- model <-> entity 매핑
- data exception -> domain failure 매핑
- data source helper의 예외 변환 규칙
- 로컬 저장소 구현의 저장/조회 흐름

예시:

- [auth_user_mapper_test.dart](../apps/mobile/test/features/auth/data/auth_user_mapper_test.dart)
- [auth_repository_error_handler_test.dart](../apps/mobile/test/features/auth/data/auth_repository_error_handler_test.dart)
- [supabase_auth_data_source_error_handler_test.dart](../apps/mobile/test/features/auth/data/supabase_auth_data_source_error_handler_test.dart)
- [chat_repository_impl_test.dart](../apps/mobile/test/features/chat/data/repository/chat_repository_impl_test.dart)

### Presentation

다음 내용을 우선 검증합니다.

- Cubit/Bloc 상태 전이
- 사용자 입력 검증
- 주요 페이지 상호작용
- 리스트와 페이징 상태 변화

예시:

- [sign_in_cubit_test.dart](../apps/mobile/test/features/auth/presentation/cubit/sign_in_cubit_test.dart)
- [sign_in_page_test.dart](../apps/mobile/test/features/auth/presentation/pages/sign_in_page_test.dart)
- [chat_message_list_bloc_test.dart](../apps/mobile/test/features/chat/presentation/bloc/chat_message_list_bloc_test.dart)
- [cursor_pagination_bloc_test.dart](../apps/mobile/test/core/pagination/cursor_pagination_bloc_test.dart)

## 무엇을 테스트하지 않는가

기본적으로 아래 항목은 직접 테스트 우선순위를 낮게 둡니다.

- generated file의 세부 구현
- Supabase SDK 자체 동작
- 단순 getter/setter만 있는 코드
- 화면 전체를 무겁게 붙잡는 광범위한 end-to-end 대체성 테스트

## 테스트 명령어

전체 테스트:

```bash
cd apps/mobile
flutter test
```

인증 feature만 실행:

```bash
cd apps/mobile
flutter test test/features/auth
```

분석 포함 최소 검증:

```bash
cd apps/mobile
flutter analyze
flutter test
```

## 테스트 추가가 필요한 경우

다음 변경은 테스트를 같이 갱신하는 것을 기본으로 봅니다.

- business flow 변경
- routing rule 변경
- shared extension 변경
- validation rule 변경
- repository failure mapping 변경

## 테스트 데이터와 지원 코드

feature 테스트에서 공통 가짜 구현체가 필요하면 `test/features/<feature>/support`에 둡니다.

예시:

- [fake_auth_repository.dart](../apps/mobile/test/features/auth/support/fake_auth_repository.dart)
- [fake_chat_repository.dart](../apps/mobile/test/features/chat/support/fake_chat_repository.dart)
