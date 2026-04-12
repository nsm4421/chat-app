# 테이블 레퍼런스

이 문서는 현재 Supabase migration 기준의 실제 테이블 구조를 설명한다.
기준 migration은 [20260412110000_rebuild_replay_investment_schema.sql](/Users/n/Desktop/pg/supabase/migrations/20260412110000_rebuild_replay_investment_schema.sql) 이다.

## 범위

현재 앱에서 유지되는 핵심 데이터 축은 아래와 같다.

- 사용자: `profiles`, `user_account_state`
- 시장 replay: `market_assets`, `market_replay_days`, `market_replay_ticks`, `market_replay_candles`
- 플레이: `game_seasons`, `investment_sessions`, `investment_positions`, `investment_orders`, `investment_results`
- 랭킹: `season_ranking_entries`
- 커뮤니티: `investment_posts`, `investment_post_reactions`, `investment_post_comments`

## 사용자

### `public.profiles`

역할:
- `auth.users`와 1:1로 연결되는 앱 프로필 루트 테이블
- 공개 프로필 정보와 커뮤니티 표시용 사용자 정보 보관

주요 컬럼:
- `id`: `auth.users.id`와 동일한 PK
- `email`: auth email 복사본
- `username`: 공개 핸들, unique
- `avatar_url`: 아바타 이미지 URL
- `bio`: 소개 문구
- `onboarding_completed`: 온보딩 완료 여부

관계:
- 여러 커뮤니티/랭킹 view에서 작성자 표시용으로 join

RLS:
- 인증 사용자는 프로필 조회 가능
- 본인만 insert/update 가능

트리거:
- `handle_new_user_profile()`: auth 유저 생성 시 profile 자동 생성
- `handle_profiles_updated_at()`: update 시 `updated_at` 자동 갱신

비고:
- 과거 `display_name` 컬럼은 제거됐다. 현재 공개 식별자는 `username` 중심이다.

### `public.user_account_state`

역할:
- 운영 상태와 접근 제어용 계정 상태 저장

주요 컬럼:
- `user_id`: `auth.users.id`와 1:1 PK
- `is_dormant`: 휴면 여부
- `is_banned`: 영구 차단 여부
- `is_suspended`: 일시 정지 여부
- `last_seen_at`: 최근 활동 시각

관계:
- `create_investment_session()`에서 플레이 가능 여부 검사에 사용

RLS:
- 본인만 조회 가능

트리거 및 함수:
- `handle_new_user_account_state()`: auth 유저 생성 시 상태 행 자동 생성
- `handle_user_account_state_updated_at()`: update 시 `updated_at` 갱신
- `touch_current_user_account_state()`: 현재 사용자 최근 활동 시각 갱신 RPC

## 시장 Replay

### `public.market_assets`

역할:
- replay에서 거래 가능한 코인 메타데이터 저장

주요 컬럼:
- `id`: PK
- `symbol`: 예: `BTC-KRW`
- `base_asset`: 예: `BTC`
- `quote_asset`: 예: `KRW`
- `display_name`: 사용자 표시명
- `exchange`: 거래소 구분
- `category`: 선택적 카테고리
- `is_active`: 현재 사용 가능 여부

관계:
- `market_replay_ticks`, `market_replay_candles`, `investment_positions`, `investment_orders`에서 참조

RLS:
- 인증 사용자 전체 조회 가능

트리거:
- `touch_updated_at()` 공용 트리거로 `updated_at` 갱신

### `public.market_replay_days`

역할:
- 사용자가 선택하는 기준 날짜와 실제 재생할 과거 거래일을 묶는 replay 단위

주요 컬럼:
- `id`: PK
- `reference_date`: 사용자가 앱에서 선택하는 기준 날짜
- `source_market_date`: 실제 replay 원본이 되는 전 거래일
- `exchange`: 거래소
- `quote_asset`: 기준 통화
- `status`: `collecting | ready | failed | archived`
- `source_started_at`, `source_finished_at`: 적재 작업 시각

관계:
- `market_replay_ticks`, `market_replay_candles`, `investment_sessions`, `investment_results`에서 참조

RLS:
- `status = 'ready'` 인 행만 인증 사용자가 조회 가능

트리거:
- `touch_updated_at()` 공용 트리거 적용

비고:
- `source_market_date < reference_date` 제약이 있다.

### `public.market_replay_ticks`

역할:
- replay 재생의 원본 이벤트 스트림

주요 컬럼:
- `id`: identity PK
- `replay_day_id`: replay day FK
- `sequence_no`: replay 전체 순서
- `asset_id`: 자산 FK
- `event_time`: 원본 시장 시각
- `trade_price`: 체결 가격
- `trade_volume`, `acc_trade_volume`, `acc_trade_price`: 거래량 누적 정보

관계:
- 주문 체결 가격 계산과 세션 valuation에 사용

RLS:
- 연결된 `market_replay_days.status = 'ready'` 인 데이터만 조회 가능

비고:
- unique key는 `(replay_day_id, sequence_no)`다.
- 현재 설계는 자산별 sequence가 아니라 replay 전체 공통 sequence를 전제로 한다.

### `public.market_replay_candles`

역할:
- 차트 렌더링용 미리 집계된 candle 데이터

주요 컬럼:
- `replay_day_id`, `asset_id`
- `interval`: `1m | 5m | 15m | 1h | 4h | 1d`
- `candle_at`
- `open_price`, `high_price`, `low_price`, `close_price`
- `volume`, `quote_volume`

관계:
- 차트 UI에서 직접 사용

RLS:
- 연결된 `market_replay_days.status = 'ready'` 인 데이터만 조회 가능

비고:
- PK는 `(replay_day_id, asset_id, interval, candle_at)`이다.

## 플레이

### `public.game_seasons`

역할:
- 시즌 모드 규칙과 기간 정의

주요 컬럼:
- `id`
- `name`, `description`
- `status`: `upcoming | active | settled | archived`
- `starts_at`, `ends_at`
- `initial_balance`
- `allowed_reference_date_from`, `allowed_reference_date_to`
- `allowed_exchange`, `allowed_quote_asset`

관계:
- `investment_sessions`, `investment_results`, `season_ranking_entries`가 참조

RLS:
- 인증 사용자 전체 조회 가능

트리거:
- `touch_updated_at()` 공용 트리거 적용

비고:
- 시즌 모드 세션 생성 시 허용 날짜/거래소/통화 범위를 검사한다.

### `public.investment_sessions`

역할:
- 한 번의 replay 플레이 세션 상태 저장

주요 컬럼:
- `id`
- `user_id`
- `replay_day_id`
- `season_id`
- `mode`: `practice | challenge | season`
- `start_balance`
- `cash_balance`
- `total_equity`
- `return_rate`
- `current_sequence_no`
- `trade_count`
- `status`: `in_progress | finished | abandoned`
- `started_at`, `finished_at`

관계:
- `investment_positions`, `investment_orders`, `investment_results`, `investment_posts`의 부모

RLS:
- 본인 세션만 조회 가능
- 단, 인증 게시글로 공개된 세션은 다른 사용자도 조회 가능

주요 트리거:
- `before_investment_session_update()`
  - 기준 정보 변경 차단
  - sequence 되감기 차단
  - replay 범위 검증
  - 현재 보유 포지션 기준으로 `total_equity`, `return_rate` 재계산
- `sync_investment_result_from_session()`
  - 세션이 `finished` 되면 `investment_results` upsert

관련 RPC:
- `create_investment_session()`
- `advance_investment_session()`
- `finish_investment_session()`

비고:
- `status = 'in_progress'` 인 세션은 사용자당 1개만 허용한다.

### `public.investment_positions`

역할:
- 세션 중 현재 보유 자산 상태를 빠르게 조회하기 위한 materialized snapshot

주요 컬럼:
- `session_id`, `asset_id`: 복합 PK
- `quantity`
- `average_buy_price`
- `updated_at`

관계:
- `investment_sessions`와 `market_assets`에 종속

RLS:
- 자신의 세션에 속한 포지션만 조회 가능

트리거:
- 직접 트리거는 없고, 주문 insert 후 `after_investment_order_insert()`에서 갱신

### `public.investment_orders`

역할:
- replay 시점 기준 실제 체결된 주문 기록

주요 컬럼:
- `id`
- `session_id`
- `asset_id`
- `side`: `buy | sell`
- `quantity`
- `price`
- `executed_sequence_no`
- `executed_at`
- `created_at`

관계:
- 세션과 자산을 참조

RLS:
- 자신의 세션 주문만 조회 가능

주요 트리거:
- `before_investment_order_insert()`
  - 세션 소유자 검증
  - 진행 중 세션 여부 확인
  - 주문 시점과 현재 replay 위치 일치 여부 검사
  - replay tick에서 실제 체결 가격과 시각 강제
  - buy 시 잔고, sell 시 보유 수량 검증
- `after_investment_order_insert()`
  - 포지션 수량/평단 갱신
  - 세션 현금 잔고 및 거래 횟수 갱신

관련 RPC:
- `place_investment_order()`

비고:
- 클라이언트가 넣는 `price`, `executed_at` 값은 실질적으로 무시되고 replay 데이터로 덮어쓴다.

### `public.investment_results`

역할:
- 종료된 세션의 확정 결과 저장

주요 컬럼:
- `session_id`: PK
- `user_id`
- `replay_day_id`
- `season_id`
- `final_balance`
- `final_return_rate`
- `trade_count`
- `finished_at`

관계:
- `investment_sessions` 종료 결과 스냅샷
- `season_ranking_entries`, `investment_post_overview`의 근거 데이터

RLS:
- 본인 결과 조회 가능
- `season_id`가 있는 결과 또는 인증 게시글에 연결된 결과는 공개 조회 가능

트리거:
- `sync_season_ranking_from_result()`
  - 시즌 결과면 랭킹 엔트리 갱신

### `public.season_ranking_entries`

역할:
- 시즌별 사용자 최고 기록 스냅샷

주요 컬럼:
- `season_id`, `user_id`: 복합 PK
- `best_session_id`
- `score`
- `return_rate`
- `final_balance`
- `trade_count`
- `rank`

관계:
- `game_seasons`, `investment_sessions` 참조

RLS:
- 인증 사용자 전체 조회 가능

트리거 및 함수:
- `sync_season_ranking_from_result()`
- `refresh_season_ranking()`

비고:
- 현재 MVP에서는 `score`가 `final_return_rate`와 동일하게 동작한다.

## 커뮤니티

### `public.investment_posts`

역할:
- 종료된 플레이 결과를 인증 게시물로 공개하는 피드 본문

주요 컬럼:
- `id`
- `user_id`
- `session_id`
- `title`
- `body`
- `created_at`, `updated_at`

관계:
- 세션당 게시물 1개를 전제로 `session_id` unique

RLS:
- 모든 인증 사용자가 조회 가능
- 본인만 insert/update/delete 가능

주요 트리거:
- `validate_investment_post_session()`
  - 게시글 작성자와 세션 소유자 일치 여부 검사
  - 세션이 `finished` 인지 검사
  - `investment_results`가 생성된 세션만 허용
  - update 시 `session_id`, `user_id` 변경 차단

### `public.investment_post_reactions`

역할:
- 인증 게시글 반응 저장

주요 컬럼:
- `post_id`
- `user_id`
- `reaction`: 현재는 `like`만 지원
- `created_at`

관계:
- 게시글에 종속

RLS:
- 인증 사용자 전체 조회 가능
- 본인 반응만 insert/delete 가능

비고:
- PK는 `(post_id, user_id, reaction)`이다.

### `public.investment_post_comments`

역할:
- 인증 게시글 댓글 저장

주요 컬럼:
- `id`
- `post_id`
- `user_id`
- `body`
- `created_at`, `updated_at`

관계:
- 게시글에 종속

RLS:
- 인증 사용자 전체 조회 가능
- 본인 댓글만 insert/update/delete 가능

트리거:
- `touch_updated_at()` 공용 트리거 적용

## View

### `public.season_ranking_overview`

역할:
- 시즌 랭킹과 프로필 표시 정보를 같이 읽는 read model

포함 정보:
- 랭킹 지표
- `profiles.username`, `profiles.avatar_url`
- 시즌 이름, 시즌 상태

### `public.investment_post_overview`

역할:
- 인증 피드 화면용 read model

포함 정보:
- 게시글 본문
- 작성자 프로필
- 연결된 세션/결과 성과값
- 기준 날짜와 replay 원본 날짜
- 반응 수, 댓글 수, 내가 좋아요 눌렀는지 여부

## 비테이블 리소스

### `storage.buckets.avatars`

역할:
- 사용자 아바타 저장 버킷

정책:
- 공개 읽기 허용
- 인증 사용자는 자신의 user id 폴더 아래만 insert/update/delete 가능

## 권장 읽기 순서

스키마를 이해할 때는 아래 순서가 가장 자연스럽다.

1. `profiles`, `user_account_state`
2. `market_assets`, `market_replay_days`, `market_replay_ticks`, `market_replay_candles`
3. `game_seasons`, `investment_sessions`, `investment_positions`, `investment_orders`, `investment_results`
4. `season_ranking_entries`
5. `investment_posts`, `investment_post_reactions`, `investment_post_comments`
