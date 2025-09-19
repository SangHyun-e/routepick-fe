// 보호가 필요한 경로 목록
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/auth_state.dart';
import 'package:route_pick_fe/features/auth/login_screen.dart';
import 'package:route_pick_fe/features/home/home_screen.dart';

final _protectedPaths = <String>{'/me', '/write'};

// GoRouter를 Riverpod로 감싸서 auth 상태 기반 redirect 수행
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(authStatusProvider.notifier).stream,
    ),
    redirect: (context, state) {
      final isLoggedIn = ref.read(authStatusProvider);
      final goingTo = state.matchedLocation;

      final isProtected = _protectedPaths.any((p) => goingTo.startsWith(p));
      if (isProtected && !isLoggedIn) {
        return '/login?from=${Uri.encodeComponent(goingTo)}';
      }
      // 로그인 상태에서 /login 으로 가면 홈으로 보냄(선택)
      if (goingTo == '/login' && isLoggedIn) {
        return '/';
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      // 보호 라우트
      GoRoute(
        path: '/me',
        builder: (c, s) =>
            const Scaffold(body: Center(child: Text('My Page (Protected)'))),
      ),
      GoRoute(
        path: '/write',
        builder: (c, s) =>
            const Scaffold(body: Center(child: Text('Write Post (Protected)'))),
      ),
    ],
  );
});

// go_router에서 auth 상태가 바뀌었음을 감지해주는 헬퍼
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
