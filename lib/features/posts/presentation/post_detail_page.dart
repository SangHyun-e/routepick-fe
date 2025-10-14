import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_pick_fe/features/state/posts_providers.dart';

class PostDetailPage extends ConsumerWidget {
  final String id;
  const PostDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(postDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: Text('Post $id')),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패: $e')),
        data: (post) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(post.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              if (post.summary != null) Text(post.summary!),
              const SizedBox(height: 24),
              const Text('(본문 / 메타데이터는 이후 단계에서 확장)'),
            ],
          ),
        ),
      ),
    );
  }
}
