import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/presentation/home_page.dart';
import 'package:route_pick_fe/features/auth/presentation/login_page.dart';
import 'package:route_pick_fe/features/auth/presentation/me_page.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

// 보호할 경로
const _protectedPaths = {'/me', '/write'};

final routerProvider = Provider<GoRouter>((ref) {
  // 토큰이 바뀌면 라우터에 새로고침 신호를 줄 리스너
  final refresh = ValueNotifier(0);
  ref.listen<String?>(accessTokenProvider, (_, __) => refresh.value++);

  String? token() => ref.read(accessTokenProvider);
  bool authed() => token() != null && token()!.isNotEmpty;

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    //  전역 redirect: 어떤 경로로 가든 먼저 여기서 판단
    redirect: (context, state) {
      final path = state.matchedLocation; // '/me'
      final going = state.uri.toString(); // '/me?x=1' 등 전체

      // 보호 경로인데 비로그인 → 로그인으로 보냄
      if (!authed() && _protectedPaths.any((p) => path.startsWith(p))) {
        return '/login?from=${Uri.encodeComponent(going)}';
      }
      // 로그인 상태에서 /login 가면 원래 가려던 곳(or 홈)으로
      if (authed() && path == '/login') {
        final from = state.uri.queryParameters['from'];
        return from ?? '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/me', builder: (_, __) => const MePage()),
    ],
  );
});
