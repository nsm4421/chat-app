# Chat Feature

`chat`은 공개 그룹 채팅방 탐색, 참여 중인 채팅방 목록, 이후의 메시징 흐름까지 포함하는 채팅 도메인 기능입니다.

## 현재 설계 방향

- 핵심 엔티티는 `chat room`입니다.
- `group`과 `private`를 별도 테이블로 나누지 않고 `chat_rooms` 단일 테이블로 관리합니다.
- Discover 화면에는 `type = 'group'` 이면서 `is_public = true` 인 방만 노출합니다.
- 1:1 대화는 같은 테이블을 쓰되 `type = 'private'` 로 구분합니다.

## 테이블 구조

### `public.chat_rooms`

- `id`
- `created_by`
- `type`
  - `private`
  - `group`
- `title`
- `description`
- `tags`
- `max_participants`
- `status`
  - `draft`
  - `open`
  - `full`
  - `archived`
  - `closed`
- `is_public`
- `last_message_at`
- `created_at`
- `updated_at`

### `public.chat_room_members`

- `chat_room_id`
- `user_id`
- `is_host`
- `joined_at`

## 설계 의도

이 구조를 택한 이유는 다음과 같습니다.

- Discover, Inbox, 참여 중인 채팅방 목록을 하나의 room 모델로 다룰 수 있습니다.
- `group`과 `private`를 같은 테이블에 두면 공통 로직이 중복되지 않습니다.
- 이후 private chat을 group chat으로 확장하거나 반대로 제한하는 요구가 생겨도 유연합니다.

## 주요 규칙

- `group` 방은 제목과 설명이 필요합니다.
- `private` 방은 공개될 수 없고 `max_participants`가 항상 2입니다.
- Discover 노출 대상은 공개 그룹 방이며 상태는 보통 `open`, 필요하면 `full`까지 포함합니다.
- 방 생성자는 자동으로 `chat_room_members`에 host 멤버로 추가됩니다.

## RLS 정책 요약

### `chat_rooms`

- 인증 사용자는 아래 경우에 방을 조회할 수 있습니다.
  - 내가 만든 방
  - 내가 멤버인 방
  - 공개 그룹 방이며 상태가 `open` 또는 `full` 인 방
- 생성/수정/삭제는 기본적으로 방 생성자만 가능합니다.

### `chat_room_members`

- 인증 사용자는 아래 경우에 멤버 정보를 조회할 수 있습니다.
  - 내가 속한 방
  - 공개 그룹 방
- 공개 그룹 방에는 본인이 직접 참여할 수 있습니다.
- 방 생성자는 멤버를 내보낼 수 있고, 사용자는 본인을 직접 나갈 수 있습니다.

## validation 규칙

SQL 제약과 앱 validation 규칙은 아래 파일을 기준으로 맞춥니다.

- [chat_room_field_rules.dart](/Users/n/Desktop/pg/lib/features/chat/domain/validation/chat_room_field_rules.dart)
- [chat_room_input_validator.dart](/Users/n/Desktop/pg/lib/features/chat/domain/validation/chat_room_input_validator.dart)

현재 기준 규칙:

- group title: 2~60자
- group description: 2~200자
- private participants: 2명 고정
- group participants: 2~50명
- tags: 최대 8개
- tag 한 개 길이: 최대 20자

## migration 파일

현재 스키마는 아래 migration에 기록합니다.

- [20260322124735_create_chat_rooms.sql](/Users/n/Desktop/pg/supabase/migrations/20260322124735_create_chat_rooms.sql)

## Supabase 명령어

새 migration 파일 생성:

```bash
supabase migration new create_chat_rooms
```

로컬 DB 반영:

```bash
supabase db reset
```

이미 실행 중인 로컬 DB에 pending migration만 적용:

```bash
supabase migration up
```

원격 프로젝트 반영:

```bash
supabase db push
```
