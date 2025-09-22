import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('홈')),
      body: Center(
        child: Wrap(
          spacing: 12,
          children: [
            FilledButton(
              onPressed: () => context.go('/login'),
              child: const Text('로그인'),
            ),
            FilledButton.tonal(
              onPressed: () => context.go('/me'),
              child: const Text('내 정보'),
            ),
          ],
        ),
      ),
    );
  }
}
