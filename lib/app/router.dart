// router.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/presentation/home_page.dart';
import 'package:route_pick_fe/features/auth/presentation/login_page.dart';
import 'package:route_pick_fe/features/auth/presentation/me_page.dart';
import 'package:route_pick_fe/features/posts/presentation/post_detail_page.dart';
import 'package:route_pick_fe/features/posts/presentation/post_write_page.dart';
import 'package:route_pick_fe/features/posts/presentation/posts_list_page.dart';
import 'package:route_pick_fe/features/splash/presentation/splash_page.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

const _protectedPaths = {'/me', '/posts/write'};

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final path = state.matchedLocation;
      final uri = state.uri;
      final fullLocation = uri.toString();
      final authed = (notifier.token ?? '').isNotEmpty;

      if (!notifier.bootstrapped) {
        if (path == '/splash') return null;
        return Uri(
          path: '/splash',
          queryParameters: {'from': fullLocation},
        ).toString();
      }

      if (path == '/splash') {
        final fromParam = uri.queryParameters['from'];
        if (!authed) {
          if (fromParam == null || fromParam.isEmpty) return '/';
          final fromUri = Uri.tryParse(fromParam);
          final fromPath = fromUri?.path ?? fromParam;
          final needsLogin =
              _protectedPaths.any((protected) => fromPath.startsWith(protected));
          if (needsLogin) {
            return Uri(
              path: '/login',
              queryParameters: {'from': fromParam},
            ).toString();
          }
          return fromParam;
        }
        return fromParam ?? '/';
      }

      if (!authed) {
        if (path == '/login') return null;
        final protected =
            _protectedPaths.any((protected) => path.startsWith(protected));
        if (!protected) return null;
        return Uri(
          path: '/login',
          queryParameters: {'from': fullLocation},
        ).toString();
      }

      if (path == '/login') {
        final fromParam = uri.queryParameters['from'];
        return fromParam ?? '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, state) => SplashPage(
          initialTarget: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(path: '/', builder: (_, __) => const HomePage()),
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/me', builder: (_, __) => const MePage()),
      GoRoute(path: '/posts', builder: (_, __) => const PostsListPage()),
      GoRoute(path: '/posts/write', builder: (_, __) => const PostWritePage()),
      GoRoute(
        path: '/posts/:id',
        builder: (_, s) {
          return PostDetailPage(id: s.pathParameters['id']!);
        },
      ),
    ],
  );
});
