import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RoutePick Home')),
      body: Center(
        child: FilledButton(
          onPressed: () => context.go('/login'),
          child: const Text('로그인 페이지 이동'),
        ),
      ),
    );
  }
}
