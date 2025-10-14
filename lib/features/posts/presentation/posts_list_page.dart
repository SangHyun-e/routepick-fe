import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/state/posts_providers.dart';

class PostsListPage extends ConsumerWidget {
  const PostsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postsListControllerProvider);
    final notifier = ref.read(postsListControllerProvider.notifier);

    Widget buildBody() {
      if (state.isLoading && state.items.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.error != null && state.items.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('불러오기 실패: ${state.error}'),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: notifier.loadFirst,
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        );
      }
      if (state.items.isEmpty) {
        return const Center(child: Text('게시글이 없습니다.'));
      }

      // 스크롤 끝 근처에서 자동 더보기
      return NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
            notifier.loadMore();
          }
          return false;
        },
        child: RefreshIndicator(
          displacement: 56,
          edgeOffset: 8,
          onRefresh: () => notifier.loadFirst(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount:
                state.items.length +
                ((state.isLoadingMore || state.hasMore) ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              if (i < state.items.length) {
                final p = state.items[i];
                return ListTile(
                  title: Text(p.title),
                  subtitle: p.summary == null
                      ? null
                      : Text(
                          p.summary!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () => context.go('/posts/${p.id}'),
                );
              }
              // footer
              if (state.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              // hasMore 이지만 아직 로딩 아닌 순간(트리거 전)엔 살짝 여백
              if (state.hasMore) {
                return const SizedBox(height: 56);
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text('마지막 페이지입니다.')),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Posts')),
      body: buildBody(),
    );
  }
}
