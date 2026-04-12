import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/features/home/mock/home_mock_data.dart';
import 'package:domodachi/features/home/mock/mock_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockSessionResultPage extends StatelessWidget {
  const MockSessionResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MockDetailPageScaffold(
      title: 'Session Result',
      subtitle: '플레이가 끝난 뒤 수익률 요약, 체결 회고, 인증 카드 미리보기를 한 화면에 모은 결과 페이지입니다.',
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.push(AppRoutePath.mockSeasonDetail),
                  child: const Text('시즌 보드 보기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.push(AppRoutePath.mockProofDetail),
                  child: const Text('인증 카드 열기'),
                ),
              ),
            ],
          ),
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: colorScheme.primaryContainer,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BTC Breakout 세션 종료',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '총 수익률 +12.84%로 종료했습니다. 최고점 대비 드로다운을 줄이면서 14회 체결로 세션을 마무리한 설정입니다.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: MockStatCard(
                      label: '최종 자산',
                      value: '₩11,284,000',
                      valueColor: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MockStatCard(
                      label: '순이익',
                      value: '+₩1,284,000',
                      valueColor: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: MockStatCard(
                      label: '승률',
                      value: '71%',
                      valueColor: colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const MockPageSectionTitle(
          title: '체결 회고',
          subtitle: '결과 페이지에서 바로 복기할 수 있는 간단한 타임라인입니다.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                MockStepTile(
                  title: '09:12 눌림 매수 진입',
                  description: '초반 급등 후 되돌림 구간에서 25% 비중으로 1차 진입했습니다.',
                  icon: Icons.call_made_rounded,
                ),
                MockStepTile(
                  title: '09:26 추세 확인 후 추가 매수',
                  description: '고점 돌파 신호 뒤 다시 25%를 더해 평균 단가를 끌어올렸습니다.',
                  icon: Icons.add_chart_rounded,
                ),
                MockStepTile(
                  title: '09:41 분할 익절 마감',
                  description: '급등 피로가 보이는 시점에서 2번 나눠 정리하며 수익을 확정했습니다.',
                  icon: Icons.savings_outlined,
                  showDivider: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MockPageSectionTitle(
          title: '인증 카드 미리보기',
          subtitle: '결과가 콘텐츠가 되는 방향을 보여주는 핵심 카드입니다.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      child: const Text('나'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Replay Sprint 인증 카드',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '+12.84%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.tertiaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BTC Breakout 완주',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '14회 체결 · 승률 71% · 최고 수익 구간 BTC/KRW',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: const [
                          MockInfoChip(label: '12분 세션'),
                          MockInfoChip(label: 'BTC/KRW'),
                          MockInfoChip(label: '분할 익절'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MockPageSectionTitle(
          title: '다음 액션',
          subtitle: '결과 이후 유저가 자연스럽게 이동할 목적지를 제안합니다.',
        ),
        const SizedBox(height: 12),
        ...mockResultActions.map(
          (action) => Padding(
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
                    action.icon,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(
                  action.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(action.description),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
