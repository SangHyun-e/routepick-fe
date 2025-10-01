import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_pick_fe/app/router.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boot = ref.watch(bootProvider);
    return boot.when(
      loading: () => const _Splash(),
      error: (_, __) => const _Splash(error: true),
      data: (_) {
        final router = ref.watch(routerProvider);
        return MaterialApp.router(
          routerConfig: router,
          title: 'RoutePick',
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        );
      },
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash({this.error = false});
  final bool error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: error
              ? const Text('초기화 실패. 다시 실행해 주세요.')
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
