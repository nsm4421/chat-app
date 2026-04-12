import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/features/home/mock/home_mock_data.dart';
import 'package:domodachi/features/home/mock/mock_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MockSeasonDetailPage extends StatelessWidget {
  const MockSeasonDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MockDetailPageScaffold(
      title: 'Season Detail',
      subtitle: '세션 결과가 시즌 경쟁으로 이어지는 구조를 보여주는 랭킹 상세 화면입니다.',
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: FilledButton.icon(
            onPressed: () => context.push(AppRoutePath.mockReplaySetup),
            icon: const Icon(Icons.replay_circle_filled_outlined),
            label: const Text('새 replay 도전하기'),
          ),
        ),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Replay Sprint Season 01',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '매주 갱신되는 시즌 보드입니다. 단순 수익률뿐 아니라 플레이 수, 인증 카드 반응, 연속 완주 수치를 같이 보여주도록 구성했습니다.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
              ),
              const SizedBox(height: 18),
              Row(
                children: const [
                  Expanded(
                    child: MockStatCard(label: '참여자', value: '2,438명'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: MockStatCard(label: '내 순위', value: '#18'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: MockStatCard(label: '잔여 기간', value: '2일'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const MockPageSectionTitle(
          title: '보상 티어',
          subtitle: '플레이 반복을 유도하는 시즌 보상 구조를 카드로 정리했습니다.',
        ),
        const SizedBox(height: 12),
        ...mockRewardTiers.map(
          (tier) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(tier.icon, color: colorScheme.onPrimaryContainer),
                ),
                title: Text(
                  tier.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(tier.description),
                trailing: Text(
                  tier.cut,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MockPageSectionTitle(
          title: '실시간 상위권',
          subtitle: '상위권과 내 계정을 같은 리스트에서 비교하는 방식입니다.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: mockLeaderboard
                  .map((entry) => _LeaderboardRow(entry: entry))
                  .toList(growable: false),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MockPageSectionTitle(
          title: '이번 주 미션',
          subtitle: '랭킹 외에도 반복 플레이를 유도할 추가 메타 목표입니다.',
        ),
        const SizedBox(height: 12),
        ...mockSeasonMissions.map(
          (mission) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mission.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        MockInfoChip(label: mission.progress),
                        MockInfoChip(label: mission.reward),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  const _LeaderboardRow({required this.entry});

  final MockLeaderboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: entry.isMe
            ? colorScheme.primaryContainer.withValues(alpha: 0.8)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text(
              '#${entry.rank}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${entry.badge} · ${entry.plays}판',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            entry.roi,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
