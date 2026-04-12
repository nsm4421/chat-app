# Replay 투자 스키마

이 문서는 `사용자가 선택한 기준 날짜에 대응하는 전 거래일 시장 데이터를 실시간처럼 재생하는 모의 투자앱` 기준의 초기 DB 스키마 초안이다.

현재 전제는 아래와 같다.

- 사용자는 특정 기준 날짜를 선택한다.
- 서버는 그 날짜에 대응하는 전 거래일 시장 데이터를 미리 수집해 둔다.
- 앱은 그 데이터를 순차 재생하며 보여준다.
- 호가는 MVP에서 제외한다.

## 설계 원칙

- 현재 시장 상태 저장이 아니라 `replay 데이터 저장`이 핵심이다.
- 차트용 데이터와 재생용 이벤트 데이터를 분리한다.
- 유저 주문은 어떤 replay 시점에 체결됐는지 기록해야 한다.
- 결과 인증과 랭킹을 위해 세션과 주문은 서버에서 재현 가능해야 한다.

## 1. 자산 메타

```sql
create table if not exists public.market_assets (
  id uuid primary key default gen_random_uuid(),
  symbol text not null unique,
  base_asset text not null,
  quote_asset text not null,
  display_name text not null,
  exchange text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists market_assets_exchange_quote_idx
  on public.market_assets (exchange, quote_asset, is_active);
```

예:
- `BTC-KRW`
- `ETH-KRW`

## 2. replay 날짜

```sql
create type public.market_replay_day_status as enum (
  'collecting',
  'ready',
  'failed',
  'archived'
);

create table if not exists public.market_replay_days (
  id uuid primary key default gen_random_uuid(),
  market_date date not null unique,
  exchange text not null,
  quote_asset text not null,
  status public.market_replay_day_status not null default 'ready',
  source_started_at timestamptz,
  source_finished_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);
```

역할:
- 어떤 기준 날짜에 대응하는 replay 데이터가 준비됐는지 관리

## 3. replay tick

가장 중요한 테이블이다.  
실시간처럼 보이게 하려면 순차 재생 가능한 이벤트 스트림이 필요하다.

```sql
create table if not exists public.market_replay_ticks (
  id bigserial primary key,
  replay_day_id uuid not null references public.market_replay_days (id) on delete cascade,
  asset_id uuid not null references public.market_assets (id) on delete cascade,
  sequence_no bigint not null,
  event_time timestamptz not null,
  trade_price numeric(20, 8) not null,
  trade_volume numeric(28, 12),
  acc_trade_volume numeric(28, 12),
  acc_trade_price numeric(28, 8),
  created_at timestamptz not null default timezone('utc', now()),
  unique (replay_day_id, asset_id, sequence_no)
);

create index if not exists market_replay_ticks_asset_seq_idx
  on public.market_replay_ticks (replay_day_id, asset_id, sequence_no);

create index if not exists market_replay_ticks_time_idx
  on public.market_replay_ticks (replay_day_id, event_time, sequence_no);
```

핵심 컬럼:
- `sequence_no`: 재생 순서
- `event_time`: 원본 시장 시각
- `trade_price`: 해당 시점 가격

## 4. replay candle

차트 렌더링용 데이터다.  
틱만으로 차트를 매번 만들지 않도록 미리 정리해 둔다.

```sql
create type public.market_candle_interval as enum (
  '1m',
  '5m',
  '15m',
  '1h',
  '4h',
  '1d'
);

create table if not exists public.market_replay_candles (
  replay_day_id uuid not null references public.market_replay_days (id) on delete cascade,
  asset_id uuid not null references public.market_assets (id) on delete cascade,
  interval public.market_candle_interval not null,
  candle_at timestamptz not null,
  open_price numeric(20, 8) not null,
  high_price numeric(20, 8) not null,
  low_price numeric(20, 8) not null,
  close_price numeric(20, 8) not null,
  volume numeric(28, 12) not null default 0,
  quote_volume numeric(28, 8),
  primary key (replay_day_id, asset_id, interval, candle_at)
);

create index if not exists market_replay_candles_asset_time_idx
  on public.market_replay_candles (replay_day_id, asset_id, interval, candle_at);
```

## 5. 투자 세션

```sql
create type public.investment_session_status as enum (
  'in_progress',
  'finished',
  'abandoned'
);

create type public.investment_mode as enum (
  'practice',
  'challenge',
  'season'
);

create table if not exists public.investment_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  replay_day_id uuid not null references public.market_replay_days (id) on delete restrict,
  mode public.investment_mode not null default 'practice',
  start_balance numeric(20, 8) not null,
  cash_balance numeric(20, 8) not null,
  total_equity numeric(20, 8) not null,
  return_rate numeric(18, 10) not null default 0,
  current_sequence_no bigint not null default 0,
  status public.investment_session_status not null default 'in_progress',
  started_at timestamptz not null default timezone('utc', now()),
  finished_at timestamptz,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create index if not exists investment_sessions_user_status_idx
  on public.investment_sessions (user_id, status, started_at desc);

create index if not exists investment_sessions_replay_day_idx
  on public.investment_sessions (replay_day_id, started_at desc);
```

핵심 컬럼:
- `replay_day_id`: 어떤 날짜 시장을 플레이했는지
- `current_sequence_no`: 세션이 현재 어디까지 재생됐는지

## 6. 주문 기록

```sql
create type public.investment_order_side as enum (
  'buy',
  'sell'
);

create table if not exists public.investment_orders (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.investment_sessions (id) on delete cascade,
  asset_id uuid not null references public.market_assets (id) on delete restrict,
  side public.investment_order_side not null,
  quantity numeric(28, 12) not null,
  price numeric(20, 8) not null,
  executed_sequence_no bigint not null,
  executed_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists investment_orders_session_time_idx
  on public.investment_orders (session_id, executed_sequence_no, executed_at);
```

핵심 컬럼:
- `executed_sequence_no`: 어느 replay 시점에 주문이 체결됐는지

## 7. 포지션 스냅샷

세션 중 보유 자산을 빠르게 보여주기 위한 테이블이다.

```sql
create table if not exists public.investment_positions (
  session_id uuid not null references public.investment_sessions (id) on delete cascade,
  asset_id uuid not null references public.market_assets (id) on delete restrict,
  quantity numeric(28, 12) not null default 0,
  average_buy_price numeric(20, 8) not null default 0,
  updated_at timestamptz not null default timezone('utc', now()),
  primary key (session_id, asset_id)
);
```

## 8. 플레이 결과

세션 종료 시 확정 결과를 따로 저장해 인증과 랭킹에 쓰기 쉽게 만든다.

```sql
create table if not exists public.investment_results (
  session_id uuid primary key references public.investment_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  replay_day_id uuid not null references public.market_replay_days (id) on delete restrict,
  final_balance numeric(20, 8) not null,
  final_return_rate numeric(18, 10) not null,
  trade_count integer not null default 0,
  finished_at timestamptz not null,
  created_at timestamptz not null default timezone('utc', now())
);

create index if not exists investment_results_user_idx
  on public.investment_results (user_id, finished_at desc);

create index if not exists investment_results_replay_day_idx
  on public.investment_results (replay_day_id, final_return_rate desc);
```

## MVP에서 제외하는 것

- 호가 테이블
- 호가 이력
- 실제 거래소 주문 동기화
- 실시간 외부 시장 상태 저장

## 정리

이 앱의 핵심 테이블은 아래 다섯 개다.

- `market_replay_days`
- `market_replay_ticks`
- `market_replay_candles`
- `investment_sessions`
- `investment_orders`

즉 이 앱은 `실시간 시장 조회 앱`보다 `전 거래일 시장 replay 기반 투자 시뮬레이션 게임`에 가깝다.
