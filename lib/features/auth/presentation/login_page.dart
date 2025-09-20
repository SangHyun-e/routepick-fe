import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('로그인 화면 (다음 단계에서 실제 API 연결)'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.go('/'),
              child: const Text('홈으로'),
            ),
          ],
        ),
      ),
    );
  }
}
