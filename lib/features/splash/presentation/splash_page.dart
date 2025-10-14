// features/auth/presentation/splash_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/data/auth_api.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key, this.initialTarget});

  final String? initialTarget;
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  final _api = AuthApi();
  bool _booted = false;

  void _safeGo(String location) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(location);
    });
  }

  Future<void> _boot() async {
    if (_booted) return;
    _booted = true;

    debugPrint('[Splash] boot start');

    final fromParam = widget.initialTarget;
    String? normalizeTarget(String? value) {
      if (value == null || value.isEmpty || value == '/splash') return null;
      return value;
    }
    final target = normalizeTarget(fromParam);
    bool needsLogin(String? location) {
      if (location == null) return false;
      final uri = Uri.tryParse(location);
      final path = uri?.path ?? location;
      return path.startsWith('/me') || path.startsWith('/posts/write');
    }
    final requiresLogin = needsLogin(target);
    final loginUri = Uri(
      path: '/login',
      queryParameters: target == null ? null : {'from': target},
    ).toString();

    try {
      // 1) 디스크에서 토큰 로드
      final saved = await ref.read(tokenStorageProvider).load();
      debugPrint('[Splash] saved token? ${saved != null}');
      if (saved == null || saved.isEmpty) {
        if (requiresLogin) {
          _safeGo(loginUri);
        } else {
          _safeGo(target ?? '/');
        }
        return;
      }

      // 2) 메모리에 세팅
      ref.read(accessTokenProvider.notifier).state = saved;

      // 3) 서버로 토큰 확인 (me 호출)
      await _api.me(accessToken: saved);
      debugPrint('[Splash] me OK → /');
      _safeGo(target ?? '/'); // OK이면 원래 가려던 곳 또는 홈
    } on DioException catch (e) {
      debugPrint(
        '[Splash] DioException status=${e.response?.statusCode} type=${e.type}',
      );
      // 401 등 → 토큰 삭제 후 로그인
      ref.read(accessTokenProvider.notifier).state = null;
      await ref.read(tokenStorageProvider).save(null);
      _safeGo(requiresLogin ? loginUri : (target ?? '/'));
    } catch (e) {
      debugPrint('[Splash] unknown error: $e');
      // 알 수 없는 오류 → 안전하게 로그인으로
      ref.read(accessTokenProvider.notifier).state = null;
      await ref.read(tokenStorageProvider).save(null);
      _safeGo(requiresLogin ? loginUri : (target ?? '/'));
    }
  }

  @override
  void initState() {
    super.initState();
    // 첫 프레임 이후 실행(빌드 중 네비게이션 이슈 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
