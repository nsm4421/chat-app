import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/features/home/mock/home_mock_data.dart';
import 'package:domodachi/features/home/mock/mock_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockTradingSessionPage extends StatelessWidget {
  const MockTradingSessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MockDetailPageScaffold(
      title: 'Trading Session',
      subtitle:
          '실시간 거래 앱처럼 보이는 핵심 전투 화면입니다. 차트, 주문 패널, 체결 로그, 목표 미션을 한 번에 배치했습니다.',
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('세션으로 돌아가기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push(AppRoutePath.mockSessionResult),
                  child: const Text('결과 저장 보기'),
                ),
              ),
            ],
          ),
        ),
      ),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'BTC/KRW Replay 09:42:18',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '+12.84%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const MockMiniBarChart(heights: mockCandleHeights),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: MockStatCard(
                        label: '평가 자산',
                        value: '₩11,284,000',
                        valueColor: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MockStatCard(
                        label: '미실현 손익',
                        value: '+₩1,284,000',
                        valueColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MockStatCard(
                        label: '체결 횟수',
                        value: '14회',
                        valueColor: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      MockPageSectionTitle(
                        title: '주문 패널',
                        subtitle: '앱에서 가장 자주 터치할 매매 컨트롤입니다.',
                      ),
                      SizedBox(height: 16),
                      _OrderField(label: '주문 비중', value: '25%'),
                      SizedBox(height: 10),
                      _OrderField(label: '예상 체결가', value: '₩92,180,000'),
                      SizedBox(height: 10),
                      _OrderField(label: '예상 수수료', value: '₩4,210'),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(label: '시장가 매수', buy: true),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _ActionButton(label: '시장가 매도', buy: false),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MockPageSectionTitle(
                        title: '체결 테이프',
                        subtitle: '빠른 손절과 익절 판단에 필요한 흐름입니다.',
                      ),
                      const SizedBox(height: 16),
                      ...mockTradeTape.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(child: Text(item.time)),
                              Expanded(
                                child: Text(
                                  item.price,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.side,
                                  textAlign: TextAlign.end,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: item.side == 'BUY'
                                        ? colorScheme.primary
                                        : colorScheme.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MockPageSectionTitle(
                  title: '현재 포지션',
                  subtitle: '보유 자산과 목표 미션을 한 화면에서 확인합니다.',
                ),
                const SizedBox(height: 16),
                ...mockPositions.map(
                  (position) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PositionRow(position: position),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '세션 미션',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '10분 내 수익률 +8% 달성, 손절 1회 이하, 인증 카드 업로드까지 완료하면 시즌 포인트를 추가로 획득합니다.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderField extends StatelessWidget {
  const _OrderField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.buy});

  final String label;
  final bool buy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FilledButton(
      onPressed: () {},
      style: FilledButton.styleFrom(
        backgroundColor: buy ? colorScheme.primary : colorScheme.error,
        foregroundColor: buy ? colorScheme.onPrimary : colorScheme.onError,
      ),
      child: Text(label),
    );
  }
}

class _PositionRow extends StatelessWidget {
  const _PositionRow({required this.position});

  final MockPosition position;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPositive = !position.pnlRate.startsWith('-');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  position.symbol,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${position.quantity} · ${position.averagePrice}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                position.pnlRate,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isPositive ? colorScheme.primary : colorScheme.error,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                position.exposure,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
