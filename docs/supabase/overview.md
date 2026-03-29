# Supabase Overview

이 문서는 앱과 Supabase 사이의 책임 분리, 현재 사용 중인 리소스, 운영 시 참고할 흐름을 정리합니다.

## 역할

현재 Supabase는 다음 역할을 담당합니다.

- 인증
- Postgres 데이터 저장
- RLS 기반 접근 제어
- RPC 기반 상태 전이
- Realtime 이벤트
- Storage 일부 리소스

앱에서는 Supabase SDK를 data source 경계 안에서만 직접 사용합니다.

## 저장소 구조

```text
supabase/
  migrations/
  functions/
  snippets/
```

## 주요 도메인 리소스

### Auth / Profile

- `public.profiles`
- `public.user_account_state`

관련 참고:

- [docs/schema/profiles.md](../schema/profiles.md)
- [Auth Feature](../../apps/mobile/lib/features/auth/README.md)

현재 인증 기능은 `public.profiles` 스키마를 갖고 있지만, 앱의 실제 사용자 정보 판정은 여전히 `auth.users.user_metadata`에 더 많이 의존합니다.
따라서 프로필 관련 기능을 확장할 때는 source of truth를 어디에 둘지 먼저 결정하는 것이 중요합니다.

### Friend

- `public.friend_requests`
- `public.friendships`
- 친구 관련 RPC

관련 참고:

- [Friend Feature](../../apps/mobile/lib/features/friend/README.md)
- `supabase/migrations/20260325143000_create_friends.sql`

### Chat

- `public.chat_rooms`
- `public.chat_room_members`
- `public.chat_messages`
- `public.chat_room_events`
- overview/view 계열 뷰
- alias / realtime / soft delete 관련 migration

관련 참고:

- [Chat Feature](../../apps/mobile/lib/features/chat/README.md)
- `supabase/migrations/20260322124735_create_chat_rooms.sql`
- `supabase/migrations/20260325120000_create_chat_messages_and_overview_view.sql`
- `supabase/migrations/20260325170000_create_chat_room_events.sql`

## 앱 코드에서의 연결 지점

- Supabase 초기화: [main.dart](../../apps/mobile/lib/main.dart)
- DI 제공: [register_module.dart](../../apps/mobile/lib/core/di/register_module.dart)
- Auth data source: [supabase_auth_data_source_impl.dart](../../packages/infra_supabase/lib/src/auth/supabase_auth_data_source_impl.dart)
- Friend data source: [supabase_friend_data_source_impl.dart](../../packages/infra_supabase/lib/src/friend/supabase_friend_data_source_impl.dart)
- Chat room data source: [supabase_chat_room_data_source_impl.dart](../../packages/infra_supabase/lib/src/chat/supabase_chat_room_data_source_impl.dart)
- Chat message data source: [supabase_chat_message_data_source_impl.dart](../../packages/infra_supabase/lib/src/chat/supabase_chat_message_data_source_impl.dart)

## migration 운영 원칙

- 스키마 변경은 `supabase/migrations`에 기록합니다.
- 앱 validation 규칙과 SQL 제약은 가능한 한 맞춥니다.
- soft delete가 있는 엔티티는 읽기 뷰 또는 fetch 쿼리에서 삭제 행 제외 규칙을 분명히 둡니다.
- 도메인 상태 전이가 명확한 작업은 직접 테이블 쓰기보다 RPC 사용을 우선합니다.

## 로컬 작업 명령어

새 migration 생성:

```bash
supabase migration new <name>
```

로컬 DB 초기화:

```bash
supabase db reset
```

pending migration 반영:

```bash
supabase migration up
```

원격 반영:

```bash
supabase db push
```

## 문서화 우선순위

Supabase 문서를 더 확장할 때는 아래 순서가 읽기 쉽습니다.

1. 앱이 사용하는 테이블과 RPC의 목적
2. 앱 코드에서 그 리소스를 읽고 쓰는 위치
3. RLS와 soft delete 같은 중요한 제약
4. migration 파일 경로

테이블 컬럼 전체 목록은 필요한 경우에만 별도 스키마 문서로 분리합니다.
