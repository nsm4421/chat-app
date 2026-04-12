import 'package:flutter/material.dart';

final class MockReplayPick {
  const MockReplayPick({
    required this.symbol,
    required this.scenario,
    required this.window,
    required this.volatility,
    required this.reward,
    required this.icon,
  });

  final String symbol;
  final String scenario;
  final String window;
  final String volatility;
  final String reward;
  final IconData icon;
}

final class MockProgressStep {
  const MockProgressStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isLast,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isLast;
}

final class MockPosition {
  const MockPosition({
    required this.symbol,
    required this.quantity,
    required this.averagePrice,
    required this.exposure,
    required this.pnlRate,
  });

  final String symbol;
  final String quantity;
  final String averagePrice;
  final String exposure;
  final String pnlRate;
}

final class MockProofPost {
  const MockProofPost({
    required this.author,
    required this.caption,
    required this.title,
    required this.summary,
    required this.session,
    required this.asset,
    required this.mood,
    required this.roi,
    required this.likes,
    required this.comments,
  });

  final String author;
  final String caption;
  final String title;
  final String summary;
  final String session;
  final String asset;
  final String mood;
  final String roi;
  final int likes;
  final int comments;
}

final class MockLeaderboardEntry {
  const MockLeaderboardEntry({
    required this.rank,
    required this.name,
    required this.badge,
    required this.plays,
    required this.roi,
    required this.isMe,
  });

  final int rank;
  final String name;
  final String badge;
  final int plays;
  final String roi;
  final bool isMe;
}

final class MockTradeTapeEntry {
  const MockTradeTapeEntry({
    required this.time,
    required this.price,
    required this.side,
  });

  final String time;
  final String price;
  final String side;
}

final class MockResultAction {
  const MockResultAction({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;
}

final class MockRewardTier {
  const MockRewardTier({
    required this.title,
    required this.description,
    required this.cut,
    required this.icon,
  });

  final String title;
  final String description;
  final String cut;
  final IconData icon;
}

final class MockSeasonMission {
  const MockSeasonMission({
    required this.title,
    required this.description,
    required this.progress,
    required this.reward,
  });

  final String title;
  final String description;
  final String progress;
  final String reward;
}

const mockReplayPicks = [
  MockReplayPick(
    symbol: 'BTC Breakout',
    scenario: '기준일 직전 급등장. 고점 추격과 눌림 매수 타이밍이 핵심입니다.',
    window: '2024.11.18 09:00',
    volatility: '변동성 상',
    reward: '+120P 보너스',
    icon: Icons.bolt_rounded,
  ),
  MockReplayPick(
    symbol: 'ETH Reversal',
    scenario: '장 초반 급락 뒤 반등하는 장. 손절과 재진입 감각을 연습합니다.',
    window: '2024.08.07 14:30',
    volatility: '반등 시나리오',
    reward: 'Top 30% 뱃지',
    icon: Icons.autorenew_rounded,
  ),
  MockReplayPick(
    symbol: 'SOL Trend Run',
    scenario: '상승 추세가 이어지는 장. 분할 매수와 익절 타이밍에 집중합니다.',
    window: '2025.01.14 11:20',
    volatility: '트렌드 추종',
    reward: '연승 미션 포함',
    icon: Icons.trending_up_rounded,
  ),
];

const mockProgressSteps = [
  MockProgressStep(
    title: '1. 날짜를 고르고 replay 세션 시작',
    description: '사용자가 특정 날짜를 고르면 전 거래일 시장이 실시간처럼 재생됩니다.',
    icon: Icons.calendar_month_outlined,
    isLast: false,
  ),
  MockProgressStep(
    title: '2. 매수와 매도로 포지션 운영',
    description: '호흡이 짧은 플레이를 기준으로 손익과 체결 로그를 즉시 계산합니다.',
    icon: Icons.candlestick_chart_outlined,
    isLast: false,
  ),
  MockProgressStep(
    title: '3. 결과 카드 저장과 인증 피드 업로드',
    description: '세션 종료 후 수익률, 승률, 대표 체결을 카드로 만들어 공유합니다.',
    icon: Icons.verified_outlined,
    isLast: false,
  ),
  MockProgressStep(
    title: '4. 시즌 보드에서 경쟁',
    description: '주간 시즌 랭킹과 배지를 통해 반복 플레이 동기를 유지합니다.',
    icon: Icons.emoji_events_outlined,
    isLast: true,
  ),
];

const mockPositions = [
  MockPosition(
    symbol: 'BTC/KRW',
    quantity: '0.0842 BTC',
    averagePrice: '₩89,540,000',
    exposure: '비중 42%',
    pnlRate: '+8.74%',
  ),
  MockPosition(
    symbol: 'ETH/KRW',
    quantity: '1.82 ETH',
    averagePrice: '₩4,580,000',
    exposure: '비중 29%',
    pnlRate: '+4.20%',
  ),
  MockPosition(
    symbol: 'SOL/KRW',
    quantity: '22.5 SOL',
    averagePrice: '₩204,000',
    exposure: '비중 18%',
    pnlRate: '-1.16%',
  ),
];

const mockProofPosts = [
  MockProofPost(
    author: '민준',
    caption: '12분 전 · 시즌 러너',
    title: 'BTC 급등장 추격 매매 성공',
    summary: '초반 눌림에서 2번 나눠 담고 고점 직전 정리했습니다. 수익률보다 손절 안 한 구간이 더 아쉬웠어요.',
    session: '12분 세션',
    asset: 'BTC/KRW',
    mood: '공격적 운영',
    roi: '+18.2%',
    likes: 128,
    comments: 24,
  ),
  MockProofPost(
    author: '소라',
    caption: '31분 전 · 인증 14회',
    title: 'ETH 반등 시나리오 깔끔하게 회수',
    summary: '급락 구간에서 무리하지 않고 반등 확인 후 진입했습니다. 높은 수익보다 안정적인 체결 흐름을 강조한 카드입니다.',
    session: '안정형 플레이',
    asset: 'ETH/KRW',
    mood: '보수적 운영',
    roi: '+9.6%',
    likes: 96,
    comments: 11,
  ),
  MockProofPost(
    author: '지후',
    caption: '1시간 전 · 5연승 중',
    title: 'SOL 추세장 분할 익절 루틴',
    summary:
        '세 번 나눠 팔고 남은 물량은 추세가 꺾일 때 정리했습니다. 실제 거래소 UI처럼 빠르게 판단하는 감각이 좋았습니다.',
    session: '추세 추종',
    asset: 'SOL/KRW',
    mood: '분할 익절',
    roi: '+13.1%',
    likes: 142,
    comments: 19,
  ),
];

const mockLeaderboard = [
  MockLeaderboardEntry(
    rank: 1,
    name: 'AlphaRider',
    badge: 'Top Trader',
    plays: 18,
    roi: '+34.8%',
    isMe: false,
  ),
  MockLeaderboardEntry(
    rank: 2,
    name: '코인수달',
    badge: 'Sharp Exit',
    plays: 15,
    roi: '+29.1%',
    isMe: false,
  ),
  MockLeaderboardEntry(
    rank: 3,
    name: 'BreakoutKim',
    badge: '3연승',
    plays: 22,
    roi: '+27.6%',
    isMe: false,
  ),
  MockLeaderboardEntry(
    rank: 18,
    name: '내 계정',
    badge: 'Rising',
    plays: 9,
    roi: '+12.8%',
    isMe: true,
  ),
];

const mockTradeTape = [
  MockTradeTapeEntry(time: '09:21:10', price: '₩91,840,000', side: 'BUY'),
  MockTradeTapeEntry(time: '09:24:42', price: '₩92,020,000', side: 'BUY'),
  MockTradeTapeEntry(time: '09:31:08', price: '₩92,610,000', side: 'SELL'),
  MockTradeTapeEntry(time: '09:38:24', price: '₩92,980,000', side: 'SELL'),
];

const mockResultActions = [
  MockResultAction(
    title: '인증 피드로 공유',
    description: '수익률 카드와 핵심 체결을 한 장의 콘텐츠로 올립니다.',
    icon: Icons.verified_outlined,
  ),
  MockResultAction(
    title: '시즌 랭킹 반영 확인',
    description: '내 순위와 포인트 증감을 즉시 확인할 수 있습니다.',
    icon: Icons.emoji_events_outlined,
  ),
  MockResultAction(
    title: '같은 시나리오 다시 도전',
    description: '반복 플레이를 유도하는 리플레이 루프의 시작점입니다.',
    icon: Icons.replay_rounded,
  ),
];

const mockRewardTiers = [
  MockRewardTier(
    title: 'Top Trader',
    description: '프로필 대표 배지와 메인 피드 상단 노출권을 획득합니다.',
    cut: 'Top 1%',
    icon: Icons.workspace_premium_outlined,
  ),
  MockRewardTier(
    title: 'Sharp Exit',
    description: '익절 효율이 높은 유저를 위한 서브 시즌 뱃지입니다.',
    cut: 'Top 10%',
    icon: Icons.trending_up_rounded,
  ),
  MockRewardTier(
    title: 'Consistency',
    description: '완주 횟수와 인증 업로드를 꾸준히 달성한 유저에게 지급됩니다.',
    cut: 'Top 30%',
    icon: Icons.stars_outlined,
  ),
];

const mockSeasonMissions = [
  MockSeasonMission(
    title: '3회 연속 완주',
    description: '중간 포기 없이 3판을 연속으로 끝내면 추가 포인트를 줍니다.',
    progress: '2 / 3 완료',
    reward: '+80P',
  ),
  MockSeasonMission(
    title: 'BTC 시나리오 승률 60% 달성',
    description: '대표 자산군에 대한 반복 숙련을 유도하는 미션입니다.',
    progress: '현재 54%',
    reward: '전용 배지',
  ),
];

const mockCandleHeights = <double>[
  44,
  72,
  58,
  88,
  74,
  102,
  90,
  116,
  94,
  130,
  122,
  142,
];
