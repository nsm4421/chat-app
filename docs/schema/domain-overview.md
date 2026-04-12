# 도메인 모델 초안

## 사용자

### UserAccount

- 인증 계정
- 이메일
- 생성일

### UserProfile

- userId
- username
- avatarUrl
- bio
- status
  - active
  - suspended
  - banned
- rating
- reputationScore

## 시장

### Asset

- assetId
- symbol
- name
- category
- isActive

### ReplayDay

- 사용자가 선택한 기준 날짜에 대응하는 replay 시장 단위
- replayDayId
- marketDate
- exchange
- quoteAsset
- status

### ReplayTick

- replayDayId
- symbol
- sequenceNo
- eventTime
- tradePrice
- tradeVolume

### ReplayCandle

- replayDayId
- symbol
- interval
- candleAt
- open
- high
- low
- close
- volume

## 플레이

### InvestmentSession

- sessionId
- userId
- replayDayId
- mode
- startBalance
- endBalance
- startedAt
- finishedAt
- status
- returnRate

### Position

- sessionId
- assetId
- quantity
- averageBuyPrice

### TradeOrder

- orderId
- sessionId
- symbol
- side
  - buy
  - sell
- quantity
- price
- executedSequenceNo
- executedAt

## 랭킹

### RankingEntry

- rankingId
- seasonId
- userId
- score
- returnRate
- rank

### Season

- seasonId
- name
- startedAt
- endedAt
- status

## 커뮤니티

### InvestmentPost

- postId
- userId
- sessionId
- title
- body
- createdAt

### PostReaction

- postId
- userId
- type

### PostComment

- commentId
- postId
- userId
- body
- createdAt

## 추후 확장 모델

- Friendship
- Follow
- UserBanHistory
- UserRatingHistory
- Achievement
- Report
- ReplayBookmark
