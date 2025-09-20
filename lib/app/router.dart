import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/presentation/login_page.dart';
import 'package:route_pick_fe/features/home/home_screen.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    ],
  );
}
