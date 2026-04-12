import 'package:domodachi/features/home/mock/home_mock_data.dart';
import 'package:domodachi/features/home/mock/mock_ui_kit.dart';
import 'package:flutter/material.dart';

class MockProofDetailPage extends StatelessWidget {
  const MockProofDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final post = mockProofPosts.first;

    return MockDetailPageScaffold(
      title: 'Proof Detail',
      subtitle:
          '수익 인증이 피드 콘텐츠가 되는 구조를 보여주는 상세 화면입니다. 카드, 반응, 짧은 코멘트, 연관 전략을 함께 배치했습니다.',
      children: [
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
                      child: Text(post.author.substring(0, 1)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.author,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            post.caption,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      post.roi,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.tertiaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        post.summary,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          MockInfoChip(label: post.session),
                          MockInfoChip(label: post.asset),
                          MockInfoChip(label: post.mood),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: MockStatCard(
                        label: '좋아요',
                        value: '${post.likes}',
                        valueColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MockStatCard(
                        label: '댓글',
                        value: '${post.comments}',
                        valueColor: colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MockStatCard(
                        label: '재도전율',
                        value: '38%',
                        valueColor: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MockPageSectionTitle(
          title: '작성자 메모',
          subtitle: '숏폼 느낌의 전략 코멘트와 반응 영역입니다.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: const [
                _CommentRow(
                  author: '민준',
                  message: '추격 매수는 짧게, 익절은 두 번에 나눠서 가져간 세션입니다.',
                  highlighted: true,
                ),
                SizedBox(height: 12),
                _CommentRow(
                  author: '코인수달',
                  message: '초반 눌림 확인하고 들어간 판단이 좋네요. 다음엔 손절 위치도 같이 올려주세요.',
                ),
                SizedBox(height: 12),
                _CommentRow(
                  author: 'AlphaRider',
                  message: '랭킹전에서는 익절 속도가 더 중요할 듯합니다. 그래도 완성도 높은 카드예요.',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const MockPageSectionTitle(
          title: '연관 플레이',
          subtitle: '비슷한 전략이나 장세로 이어지는 카드 추천 영역입니다.',
        ),
        const SizedBox(height: 12),
        ...mockProofPosts
            .skip(1)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 8,
                    ),
                    title: Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(item.summary),
                    trailing: Text(
                      item.roi,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _CommentRow extends StatelessWidget {
  const _CommentRow({
    required this.author,
    required this.message,
    this.highlighted = false,
  });

  final String author;
  final String message;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted
            ? colorScheme.primaryContainer.withValues(alpha: 0.65)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
