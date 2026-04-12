# 모의 투자앱 문서

이 문서 세트는 기존 소셜/채팅 앱 기획을 폐기하고, `코인 모의 투자 게임` 중심 앱으로 방향을 전환한 기준 문서다.

## 문서 구성

- [제품 개요](/Users/n/Desktop/pg/docs/planning/product-overview.md)
- [핵심 게임 루프](/Users/n/Desktop/pg/docs/planning/game-loop.md)
- [커뮤니티와 랭킹](/Users/n/Desktop/pg/docs/planning/community-and-ranking.md)
- [로드맵](/Users/n/Desktop/pg/docs/planning/roadmap.md)
- [시스템 개요](/Users/n/Desktop/pg/docs/architecture/system-overview.md)
- [도메인 모델 초안](/Users/n/Desktop/pg/docs/schema/domain-overview.md)
- [Replay 투자 스키마](/Users/n/Desktop/pg/docs/schema/replay-investment-schema.md)
- [테이블 레퍼런스](/Users/n/Desktop/pg/docs/schema/table-reference.md)

## 현재 제품 방향

- 사용자는 가상의 자산으로 코인을 거래한다.
- 거래 대상은 `플레이 기준 날짜에 대응하는 전 거래일 replay 데이터` 기반이다.
- 사용자는 특정 날짜를 선택하고, 그 기준일에 대응하는 시장이 `실시간처럼 재생`되는 흐름 안에서 투자한다.
- 플레이 목적은 수익률, 자산 증식, 시즌 성과 경쟁이다.
- 장기적으로는 플레이 기록 인증, 시즌 랭킹, 커뮤니티 확장까지 포함한다.

## 핵심 원칙

- 실투자 앱처럼 보이지 않게 `게임성`과 `모의 투자` 성격을 명확히 한다.
- 실제 실시간 시세보다 `전날 시장 replay 기반 시뮬레이션 플레이`를 우선한다.
- 커뮤니티는 단순 채팅보다 `성과 공유`, `전략 비교`, `랭킹 경쟁`에 초점을 둔다.
- 초기 버전은 기능 수보다 핵심 루프 완성도를 우선한다.
