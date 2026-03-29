# Friend Feature

`friend`는 친구 요청, 친구 수락/거절, 친구 목록 조회를 담당하는 기능입니다.

## 테이블 구조

### `public.friend_requests`

- 친구 요청 이력 테이블입니다.
- 상태는 `pending`, `accepted`, `declined`, `cancelled`를 사용합니다.
- 요청 메시지는 선택 입력이며 최대 120자입니다.

### `public.friendships`

- 실제 친구 관계를 저장하는 테이블입니다.
- 한 쌍당 1행만 저장합니다.
- `user_a_id < user_b_id` 규칙으로 `(A, B)`와 `(B, A)` 중복을 막습니다.

## RLS와 RPC

- 직접 쓰기보다 RPC를 통해 상태 전이를 처리합니다.
- `friend_requests`
  - 관련 당사자만 조회 가능
  - 본인이 요청자로 insert 가능
- `friendships`
  - 당사자만 조회 가능
  - insert/delete는 RPC에서 처리

현재 제공하는 RPC:

- `send_friend_request`
- `accept_friend_request`
- `decline_friend_request`
- `cancel_friend_request`
- `remove_friend`
- `search_friend_profiles`

## 앱 validation 규칙

SQL 제약과 맞춰서 아래 파일을 기준으로 유지합니다.

- [friend_field_rules.dart](/Users/n/Desktop/pg/packages/feature_friend/lib/domain/validation/friend_field_rules.dart)
- [friend_input_validator.dart](/Users/n/Desktop/pg/packages/feature_friend/lib/domain/validation/friend_input_validator.dart)

현재 기준 규칙:

- 친구 요청 메시지: 최대 120자
- 검색어: trim 후 빈 값이면 검색하지 않음

## migration 파일

- [20260325143000_create_friends.sql](/Users/n/Desktop/pg/supabase/migrations/20260325143000_create_friends.sql)
