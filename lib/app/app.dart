import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = buildRouter();
    return MaterialApp.router(
      title: 'RoutePick',
      routerConfig: router,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      debugShowCheckedModeBanner: false,
    );
  }
}
