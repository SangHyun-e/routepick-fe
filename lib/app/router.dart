// router.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/presentation/home_page.dart';
import 'package:route_pick_fe/features/auth/presentation/login_page.dart';
import 'package:route_pick_fe/features/auth/presentation/me_page.dart';
import 'package:route_pick_fe/features/posts/presentation/post_detail_page.dart';
import 'package:route_pick_fe/features/posts/presentation/posts_list_page.dart';
import 'package:route_pick_fe/features/splash/presentation/splash_page.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

const _protectedPaths = {'/me', '/write'};

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen<String?>(accessTokenProvider, (_, __) => refresh.value++);

  String? token() => ref.read(accessTokenProvider);
  bool authed() => (token() ?? '').isNotEmpty;

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final path = state.matchedLocation;

      // 보호 경로만 가드
      if (!authed() && _protectedPaths.any((p) => path.startsWith(p))) {
        final going = state.uri.toString();
        return '/login?from=${Uri.encodeComponent(going)}';
      }
      // 로그인된 상태에서 /login로 못 가게
      if (authed() && path == '/login') {
        final from = state.uri.queryParameters['from'];
        return from ?? '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/me', builder: (_, __) => const MePage()),
      GoRoute(path: '/posts', builder: (_, __) => const PostsListPage()),
      GoRoute(
        path: '/posts/:id',
        builder: (_, state) => PostDetailPage(id: state.pathParameters['id']!),
      ),
    ],
  );
});
