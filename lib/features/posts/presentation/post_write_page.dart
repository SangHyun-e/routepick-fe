import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/state/posts_providers.dart';

class PostWritePage extends ConsumerStatefulWidget {
  const PostWritePage({super.key});
  @override
  ConsumerState<PostWritePage> createState() => _PostWritePageState();
}

class _PostWritePageState extends ConsumerState<PostWritePage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _region = TextEditingController();
  final _tags = TextEditingController(); // "태그1, 태그2"

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _region.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = ref.read(postCreateControllerProvider);
    final notifier = ref.read(postCreateControllerProvider.notifier);

    if (state.submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final tags = _tags.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final id = await notifier.submit(
      title: _title.text.trim(),
      content: _content.text.trim(),
      region: _region.text.trim().isEmpty ? null : _region.text.trim(),
      tags: tags.isEmpty ? null : tags,
    );

    if (!mounted) return;

    if (id != null) {
      context.go('/posts/$id');
    } else {
      final err = ref.read(postCreateControllerProvider).error;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('작성 실패: $err')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postCreateControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('새 글 작성'),
        actions: [
          TextButton(
            onPressed: state.submitting ? null : _submit, // <-- 이렇게 호출
            child: state.submitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('저장'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: '제목'),
                maxLength: 120,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '제목을 입력하세요' : null,
                enabled: !state.submitting,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _content,
                decoration: const InputDecoration(labelText: '내용'),
                maxLines: 8,
                maxLength: 4000,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? '내용을 입력하세요' : null,
                enabled: !state.submitting,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _region,
                decoration: const InputDecoration(labelText: '지역(선택)'),
                enabled: !state.submitting,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _tags,
                decoration: const InputDecoration(labelText: '태그(쉼표로 구분, 선택)'),
                enabled: !state.submitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
