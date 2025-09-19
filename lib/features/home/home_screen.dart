import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RoutePick - Home (Public)')),
      body: const Center(child: Text('비회원도 접근 가능한 공개 화면')),
    );
  }
}
