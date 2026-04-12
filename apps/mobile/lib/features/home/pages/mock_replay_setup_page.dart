import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/features/home/mock/home_mock_data.dart';
import 'package:domodachi/features/home/mock/mock_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockReplaySetupPage extends StatelessWidget {
  const MockReplaySetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final featuredPick = mockReplayPicks.first;

    return MockDetailPageScaffold(
      title: 'Replay Setup',
      subtitle: '기준 날짜, 자산, 난이도를 정한 뒤 12분짜리 mock 세션을 시작하는 준비 화면입니다.',
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: FilledButton.icon(
            onPressed: () => context.push(AppRoutePath.mockTradingSession),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('이 설정으로 세션 시작'),
          ),
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [colorScheme.primary, colorScheme.tertiary],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                featuredPick.symbol,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                featuredPick.scenario,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.9),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  MockInfoChip(label: featuredPick.window),
                  MockInfoChip(label: featuredPick.volatility),
                  MockInfoChip(label: featuredPick.reward),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const MockPageSectionTitle(
          title: '세션 규칙',
          subtitle: '플레이의 긴장감과 게임성을 같이 보여주는 설정값입니다.',
        ),
        const SizedBox(height: 12),
        Row(
          children: const [
            Expanded(
              child: MockStatCard(label: '시작 자본', value: '₩10,000,000'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MockStatCard(label: '세션 길이', value: '12분'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: MockStatCard(label: '보상 포인트', value: '+120P'),
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
                  title: '플레이 스타일',
                  subtitle: '초보자용, 추세형, 경쟁형 모드를 mock chip으로 구분했습니다.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    _ModeChip(label: '튜토리얼', active: false),
                    _ModeChip(label: '표준 세션', active: true),
                    _ModeChip(label: '고변동 챌린지', active: false),
                    _ModeChip(label: '랭킹 반영', active: true),
                  ],
                ),
                const SizedBox(height: 20),
                const MockPageSectionTitle(
                  title: '세션 체크리스트',
                  subtitle: '들어가기 전 유저가 확인할 핵심 요소를 한 카드에 모았습니다.',
                ),
                const SizedBox(height: 16),
                const MockStepTile(
                  title: '기준일 전 거래일을 replay로 재생',
                  description: '시세는 고정된 과거 데이터지만 인터랙션은 실시간 거래처럼 보이게 설계합니다.',
                  icon: Icons.history_toggle_off_rounded,
                ),
                const MockStepTile(
                  title: '주문과 포지션은 즉시 손익 반영',
                  description: '주문 직후 평가 자산, 승률, 체결 로그가 바로 변하는 흐름을 시연합니다.',
                  icon: Icons.sync_alt_rounded,
                ),
                const MockStepTile(
                  title: '종료 후 결과 카드 자동 생성',
                  description: '세션 결과는 인증 피드와 시즌 랭킹으로 자연스럽게 이어집니다.',
                  icon: Icons.verified_outlined,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MockPageSectionTitle(
          title: '추천 replay 시나리오',
          subtitle: '같은 화면에서 다른 장세도 빠르게 비교할 수 있게 했습니다.',
        ),
        const SizedBox(height: 12),
        ...mockReplayPicks
            .skip(1)
            .map(
              (pick) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Icon(
                        pick.icon,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    title: Text(
                      pick.symbol,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      pick.scenario,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: active
              ? colorScheme.onPrimaryContainer
              : colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
