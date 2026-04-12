# market_replay_ingestor

`market_replay_ingestor`는 과거 코인 시세 데이터를 가져와 replay 게임용 시장 데이터로 변환한 뒤,
Postgres DB에 적재하는 순수 Dart 패키지다.

이 패키지는 앱 UI에서 직접 호출하는 패키지가 아니다.
운영 배치, 수동 적재, CLI 실행 같은 서버성 작업에 사용한다.

## 한 줄 요약

- 어디서 가져오나: `Upbit quotation API`, `Upbit quotation WebSocket`
- 무엇을 가져오나: `거래 가능 마켓 목록`, `분봉 candle`, `실시간 trade`
- 어떻게 바꾸나: `1분봉 -> pseudo tick 4개 + 다중 interval candle`, `trade -> raw trade log 저장`
- 어디에 저장하나: `market_assets`, `market_replay_days`, `market_replay_ticks`, `market_replay_candles`, `raw_market_trades`

## 왜 필요한가

앱 컨셉은 `과거 코인 데이터를 실시간처럼 재생하면서 모의 투자`하는 것이다.
그래서 앱 런타임에서 외부 거래소를 바로 읽는 구조보다,
미리 특정 날짜의 시장 데이터를 수집해서 DB에 넣어두는 구조가 더 맞다.

이 패키지는 그 사전 적재 작업을 담당한다.

## 현재 구현 범위

현재 구현은 아래 조합으로 동작한다.

- source: `Upbit minute candle API`
- source: `Upbit WebSocket trade`
- sink: `Postgres`
- replay tick 생성: `1분 candle을 open/high/low/close 4개 tick으로 확장`
- candle 집계: `1m -> 1m/5m/15m/1h/4h/1d`
- raw trade 수집: `WebSocket trade event를 원본 그대로 저장`

즉, 현재 패키지에는 두 흐름이 같이 있다.

- `과거 replay seed 적재`: 분봉 기반 deterministic replay 생성
- `실시간 원본 수집`: WebSocket raw trade 저장

아직 `raw_market_trades -> market_replay_ticks` 변환기는 구현하지 않았다.

이 점은 중요하다.

- 장점: 구현 단순, 재실행 결과 안정적, 장기 historical 적재에 유리
- 한계: 실제 tick-by-tick 시장과 완전히 동일하지는 않음

## 어떤 데이터를 어디서 가져오나

### 1. 거래 가능 마켓 목록

`UpbitMarketReplaySource`는 먼저 거래 가능한 종목 목록을 가져온다.

사용 API:

- `GET /v1/market/all`

용도:

- `market_assets` 적재용 메타 생성
- `quote_asset` 기준 필터링
- `symbols`를 명시하지 않았을 때 기본 수집 대상 선택

생성되는 메타:

- `symbol`
- `base_asset`
- `quote_asset`
- `display_name`
- `exchange`

### 2. 과거 분봉 데이터

그 다음 각 심볼별로 과거 분봉을 가져온다.

사용 API:

- `GET /v1/candles/minutes/{unit}`

용도:

- replay 원본 분봉 데이터 수집
- pseudo tick 생성
- candle 집계 생성

가져오는 원본 필드:

- `opening_price`
- `high_price`
- `low_price`
- `trade_price`
- `candle_acc_trade_volume`
- `candle_acc_trade_price`
- `candle_date_time_utc`

## 어떤 날짜를 적재하나

입력은 `referenceDate`다.

예:

- 사용자가 앱에서 `2026-04-10`을 고름
- 서버는 기본적으로 `2026-04-09` 시장 데이터를 replay용으로 적재함

기본 규칙:

- `reference_date = 사용자가 앱에서 선택하는 날짜`
- `source_market_date = 실제 replay에 쓰는 과거 시장 날짜`

현재 기본 동작:

- `source_market_date = reference_date - 1 day`

원하면 CLI에서 `--source-market-date`로 직접 덮어쓸 수 있다.

## DB에는 어디에 저장하나

현재 이 패키지가 쓰는 테이블은 아래 5개다.

### 1. `market_replay_days`

적재 시작 시 먼저 upsert 한다.

역할:

- 이 replay day가 어떤 날짜 기준인지 기록
- 적재 상태 관리

저장 필드:

- `reference_date`
- `source_market_date`
- `exchange`
- `quote_asset`
- `status`
- `source_started_at`
- `source_finished_at`

상태 변화:

- 시작: `collecting`
- 성공: `ready`
- 실패: `failed`

### 2. `market_assets`

종목 메타를 upsert 한다.

역할:

- replay tick/candle이 참조할 자산 ID 확보

저장 필드:

- `symbol`
- `base_asset`
- `quote_asset`
- `display_name`
- `exchange`
- `category`
- `is_active`

### 3. `market_replay_ticks`

실제 replay 재생용 이벤트 스트림이다.

역할:

- 앱에서 시세를 순차 재생할 때 읽는 메인 데이터

저장 필드:

- `replay_day_id`
- `sequence_no`
- `asset_id`
- `event_time`
- `trade_price`
- `trade_volume`
- `acc_trade_volume`
- `acc_trade_price`

중요:

- `sequence_no`는 자산별이 아니라 `replay_day 전체 공통 순서`다.
- 같은 replay day 안의 모든 자산 tick을 시간순으로 합쳐서 번호를 붙인다.

### 4. `market_replay_candles`

차트 렌더링용 데이터다.

역할:

- tick 전체를 클라이언트에서 다시 집계하지 않고 바로 차트 표시

저장 필드:

- `replay_day_id`
- `asset_id`
- `interval`
- `candle_at`
- `open_price`
- `high_price`
- `low_price`
- `close_price`
- `volume`
- `quote_volume`

### 5. `raw_market_trades`

실시간 WebSocket 체결 원본 저장소다.

역할:

- 앞으로 생성할 고정밀 replay의 원본 이벤트 저장
- 초단위 이하 fidelity 확보
- replay 생성 전에 체결 로그를 축적

저장 필드:

- `exchange`
- `asset_id`
- `symbol`
- `quote_asset`
- `trade_timestamp`
- `trade_timestamp_ms`
- `sequential_id`
- `trade_price`
- `trade_volume`
- `ask_bid`
- `best_ask_price`
- `best_ask_size`
- `best_bid_price`
- `best_bid_size`
- `stream_type`
- `payload`
- `received_at`

중요:

- 중복 방지는 `(exchange, symbol, sequential_id)` unique index로 처리한다.
- 이 테이블은 replay 결과가 아니라 `원본 수집 로그`다.

## 내부 동작 흐름

실제 흐름은 [lib/src/ingest_replay_day_use_case.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/ingest_replay_day_use_case.dart)에 있다.

순서는 아래와 같다.

1. `referenceDate`, `exchange`, `quoteAsset`, `symbols`를 입력받는다.
2. `sourceMarketDate`를 계산한다.
3. `market_replay_days`를 `collecting` 상태로 upsert 한다.
4. source에서 종목 목록과 분봉 데이터를 가져온다.
5. 분봉을 심볼별로 정렬한다.
6. 각 1분 candle을 pseudo tick 4개로 확장한다.
7. 모든 심볼 tick을 시간순으로 합쳐 `sequence_no`를 부여한다.
8. 1m/5m/15m/1h/4h/1d candle을 집계한다.
9. 기존 replay day의 tick/candle 데이터를 삭제하고 새 데이터로 넣는다.
10. 적재 성공 시 `ready`, 예외 발생 시 `failed`로 바꾼다.

## pseudo tick은 어떻게 만드나

현재는 실제 historical trade feed를 직접 저장하지 않는다.
대신 1분 candle 하나를 아래 4개 tick으로 확장한다.

상승 candle일 때:

- `open`
- `low`
- `high`
- `close`

하락 candle일 때:

- `open`
- `high`
- `low`
- `close`

시간 배치:

- `+0s`
- `+20s`
- `+40s`
- `+59s`

거래량 배분:

- `30%`
- `20%`
- `20%`
- `30%`

이렇게 하면 완전한 실거래 복원은 아니지만,
같은 입력에 대해 항상 같은 replay stream을 만들 수 있다.

## candle 집계는 어떻게 하나

source에서 받은 1분 candle을 기준으로 아래 interval을 다시 만든다.

- `1m`
- `5m`
- `15m`
- `1h`
- `4h`
- `1d`

집계 규칙:

- `open = 첫 candle open`
- `high = 구간 내 최고 high`
- `low = 구간 내 최저 low`
- `close = 마지막 candle close`
- `volume = 구간 합`
- `quote_volume = 구간 합`

## 어떤 코드가 어떤 역할을 하나

### CLI

[bin/market_replay_ingestor.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/bin/market_replay_ingestor.dart)

- 인자 파싱
- 환경변수/옵션 읽기
- source/sink 생성
- use case 실행
- 결과 출력

[bin/market_trade_collector.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/bin/market_trade_collector.dart)

- 종목 메타 조회
- WebSocket 구독
- raw trade batch insert
- 재연결 처리

### Command

[lib/src/ingest_replay_day_command.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/ingest_replay_day_command.dart)

- 적재 요청 파라미터
- source market date 계산

### Use Case

[lib/src/ingest_replay_day_use_case.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/ingest_replay_day_use_case.dart)

- 전체 적재 오케스트레이션
- pseudo tick 생성
- candle 집계
- sequence 부여
- 검증

### Source

[lib/src/upbit_market_replay_source.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/upbit_market_replay_source.dart)

- Upbit API 호출
- 마켓 목록 조회
- 과거 분봉 조회
- 응답을 내부 모델로 정규화

[lib/src/upbit_market_catalog_client.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/upbit_market_catalog_client.dart)

- Upbit 마켓 목록 조회
- 심볼 정규화
- replay source와 websocket collector가 공용 사용

[lib/src/upbit_trade_websocket_collector.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/upbit_trade_websocket_collector.dart)

- WebSocket 연결
- trade payload 파싱
- 버퍼 flush
- backoff 재연결

### Sink

[lib/src/postgres_replay_market_sink.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/postgres_replay_market_sink.dart)

- Postgres 연결
- replay day upsert
- asset upsert
- tick/candle replace insert
- 상태 업데이트

[lib/src/postgres_raw_market_trade_sink.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/postgres_raw_market_trade_sink.dart)

- raw trade insert
- `market_assets` upsert 재사용
- `(exchange, symbol, sequential_id)` 기준 dedupe insert

### Models

[lib/src/market_replay_models.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/lib/src/market_replay_models.dart)

- source bundle
- asset
- minute candle
- tick/candle row
- ingest result

## CLI 사용 방법

### 기본 실행

```bash
cd /Users/n/Desktop/pg/packages/market_replay_ingestor
DATABASE_URL="postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require" \
dart run bin/market_replay_ingestor.dart \
  --reference-date=2026-04-10 \
  --exchange=upbit \
  --quote-asset=SGD
```

### WebSocket raw trade 수집

```bash
cd /Users/n/Desktop/pg/packages/market_replay_ingestor
DATABASE_URL="postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require" \
dart run bin/market_trade_collector.dart \
  --exchange=upbit \
  --quote-asset=SGD \
  --symbols=SGD-BTC,SGD-ETH
```

### KRW WebSocket 수집

```bash
cd /Users/n/Desktop/pg/packages/market_replay_ingestor
DATABASE_URL="postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require" \
dart run bin/market_trade_collector.dart \
  --exchange=upbit \
  --quote-asset=KRW \
  --upbit-base-url=https://api.upbit.com \
  --upbit-websocket-url=wss://api.upbit.com/websocket/v1 \
  --symbols=KRW-BTC,KRW-ETH
```

### 심볼을 직접 지정해서 실행

```bash
cd /Users/n/Desktop/pg/packages/market_replay_ingestor
DATABASE_URL="postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require" \
dart run bin/market_replay_ingestor.dart \
  --reference-date=2026-04-10 \
  --exchange=upbit \
  --quote-asset=SGD \
  --symbols=SGD-BTC,SGD-ETH,SGD-XRP
```

### KRW 시장 실행

```bash
cd /Users/n/Desktop/pg/packages/market_replay_ingestor
DATABASE_URL="postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require" \
dart run bin/market_replay_ingestor.dart \
  --reference-date=2026-04-10 \
  --exchange=upbit \
  --quote-asset=KRW \
  --upbit-base-url=https://api.upbit.com \
  --symbols=KRW-BTC,KRW-ETH
```

### 소스 날짜를 강제로 지정

```bash
cd /Users/n/Desktop/pg/packages/market_replay_ingestor
DATABASE_URL="postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require" \
dart run bin/market_replay_ingestor.dart \
  --reference-date=2026-04-10 \
  --source-market-date=2026-04-07 \
  --exchange=upbit \
  --quote-asset=SGD \
  --symbols=SGD-BTC
```

## CLI 옵션 설명

- `--database-url`: Postgres 연결 문자열. 없으면 `DATABASE_URL` 사용
- `--reference-date`: 앱에서 보여줄 기준 날짜
- `--source-market-date`: 실제 replay 원본 날짜 override
- `--exchange`: 현재 구현상 `upbit`
- `--quote-asset`: 예: `SGD`, `KRW`
- `--symbols`: 수집할 심볼 목록. 없으면 전체 마켓 중 `market-limit`개
- `--market-limit`: 심볼 미지정 시 수집할 최대 개수
- `--minute-unit`: 현재 source 호출 분봉 단위
- `--upbit-base-url`: Upbit API base URL
- `--upbit-websocket-url`: WebSocket endpoint
- `--batch-size`: raw trade insert batch size
- `--flush-interval-ms`: raw trade flush interval
- `--ping-interval-seconds`: websocket ping interval
- `--include-snapshot`: 초기 snapshot까지 같이 저장할지 여부

## 실행 결과 출력

성공하면 대략 아래 형태로 출력한다.

```text
Replay day ingestion completed.
replay_day_id: ...
reference_date: 2026-04-10T00:00:00.000Z
source_market_date: 2026-04-09T00:00:00.000Z
asset_count: 3
tick_count: 17280
candle_count: 1296
```

## 코드에서 직접 사용하는 방법

배치 서버에서 CLI 대신 코드로 직접 호출할 수도 있다.

```dart
import 'package:market_replay_ingestor/market_replay_ingestor.dart';

Future<void> runIngest() async {
  final sink = await PostgresReplayMarketSink.open(
    'postgresql://USER:PASSWORD@HOST:5432/postgres?sslmode=require',
  );
  final source = UpbitMarketReplaySource(
    baseUrl: 'https://api.upbit.com',
  );

  try {
    final result = await IngestReplayDayUseCase(source, sink)(
      IngestReplayDayCommand(
        referenceDate: DateTime.utc(2026, 4, 10),
        exchange: 'upbit',
        quoteAsset: 'KRW',
        symbols: const ['KRW-BTC', 'KRW-ETH'],
      ),
    );

    print(result.replayDayId);
  } finally {
    await sink.close();
  }
}
```

## 검증 포인트

적재 후 최소한 아래는 확인하는 게 좋다.

- `market_replay_days.status = ready`
- `market_replay_ticks` row 수가 0보다 큰지
- `sequence_no`가 1부터 연속인지
- `market_replay_candles`가 각 interval별로 생성됐는지
- 지정한 심볼 수와 `market_assets` upsert 결과가 맞는지

예시 SQL:

```sql
select status, reference_date, source_market_date
from public.market_replay_days
where reference_date = date '2026-04-10'
  and exchange = 'upbit'
  and quote_asset = 'KRW';

select count(*), min(sequence_no), max(sequence_no)
from public.market_replay_ticks
where replay_day_id = '...';

select interval, count(*)
from public.market_replay_candles
where replay_day_id = '...'
group by interval
order by interval;
```

## 주의사항

### 1. 현재 tick은 실거래 tick이 아니다

현재 `market_replay_ticks`는 실제 trade-by-trade feed가 아니라
분봉을 replay용으로 확장한 pseudo tick이다.

즉, 이 패키지는 지금 시점에서:

- `게임 replay용`: 적합
- `정밀 체결 시뮬레이터`: 부적합

대신 새 collector는 `실시간 수집 원본`을 저장한다.
앞으로 replay 고도화는 이 `raw_market_trades`를 우선 사용하도록 확장하면 된다.

### 2. source 기본값은 SGD endpoint다

CLI 기본 `quote-asset`은 `SGD`,
기본 `upbit-base-url`은 `https://sg-api.upbit.com`이다.

KRW를 쓸 거면 `--quote-asset=KRW --upbit-base-url=https://api.upbit.com` 같이 넘기는 게 안전하다.

### 3. 재실행 시 기존 데이터는 교체된다

같은 replay day를 다시 적재하면:

- `market_replay_days`는 upsert
- 기존 `market_replay_ticks`, `market_replay_candles`는 delete 후 재insert

즉, 이 패키지는 append가 아니라 replace 방식이다.

### 4. volume이 큰 날짜는 시간이 걸릴 수 있다

심볼 수가 많을수록 Upbit 호출 수와 insert row 수가 커진다.
초기 운영은 `symbols`를 명시하고 소수 자산부터 적재하는 편이 안전하다.

## 현재 테스트 범위

테스트는 아래 파일에 있다.

- [test/ingest_replay_day_command_test.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/test/ingest_replay_day_command_test.dart)
- [test/ingest_replay_day_use_case_test.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/test/ingest_replay_day_use_case_test.dart)
- [test/upbit_trade_message_parser_test.dart](/Users/n/Desktop/pg/packages/market_replay_ingestor/test/upbit_trade_message_parser_test.dart)

현재 검증하는 내용:

- 기본 source date 계산
- pseudo tick 생성
- candle 집계
- sequence 부여
- ready/failure 상태 흐름
- websocket trade payload 파싱

## 다음 확장 후보

추후 고도화는 아래 순서가 적절하다.

1. `raw_market_trades -> market_replay_ticks` 변환기 추가
2. 실제 historical trade feed source 추가
3. exchange adapter 다중화
4. 적재 로그 테이블 추가
5. dead-letter 저장
6. staging table + swap 방식
7. 병렬 수집 + bulk copy 최적화

## 패키지 경계

이 패키지 안에서 담당하는 것:

- 과거 시장 데이터 조회
- replay 데이터 변환
- DB 적재
- 실시간 raw trade 수집

이 패키지 바깥에서 담당하는 것:

- 앱 UI
- 투자 세션 생성
- 주문 처리
- 랭킹 계산
- 커뮤니티 기능
