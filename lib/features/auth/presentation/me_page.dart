import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/data/auth_api.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

// Riverpod 소비가 필요해 ConsumerStatefulWidget 사용
class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});

  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  // 화면에 표시할 내 정보 상태
  Map<String, dynamic>? _me;
  // 로딩 상태
  bool _loading = false;
  // 에러 메시지
  String? _error;

  // API 인스턴스
  final _api = AuthApi();

  void _safeGo(String location) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(location);
    });
  }

  // 비동기: /users/me 호출
  Future<void> _loadMe() async {
    // accessToken 읽기(ref.read: 한 번 읽기)
    final token = ref.read(accessTokenProvider);
    // 로그인 안한 경우 가드
    if (token == null || token.isEmpty) {
      setState(() {
        _error = '로그인이 필요합니다';
        _me = null;
      });
      _safeGo('/login?from=%2Fme');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final map = await _api.me(accessToken: token);
      setState(() => _me = map);
    } on DioException catch (e) {
      // 인증 만료 --> 토큰 비우고 로그인으로
      if (e.response?.statusCode == 401) {
        ref.read(accessTokenProvider.notifier).state = null;
        await ref.read(tokenStorageProvider).save(null);
        _safeGo('/login?from=%2Fme');
        return;
      }
      setState(() {
        _error = '내 정보를 불러오지 못했습니다.: $e';
        _me = null;
      });
    } catch (e) {
      setState(() {
        _error = '내 정보를 불러오지 못했습니다.: $e';
        _me = null;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    final token = ref.read(accessTokenProvider);
    if (token == null || token.isEmpty) {
      _safeGo('/login');
      return;
    }

    setState(() => _loading = true);
    try {
      await _api.logout(accessToken: token);
    } catch (_) {
      // 서버 실패여도 클라 상태는 정리 (멱등)
    } finally {
      // 토큰 제거 (메모리 + 디스크)
      ref.read(accessTokenProvider.notifier).state = null;
      await ref.read(tokenStorageProvider).save(null);

      if (mounted) {
        setState(() {
          _loading = false;
          _me = null;
        });
        // 명시적 로그아웃이면 보통 from 없이 login으로
        _safeGo('/login');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 내 정보 불러오기
    _loadMe();
  }

  @override
  Widget build(BuildContext context) {
    // 간단 UI
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        actions: [
          if (_me != null)
            IconButton(
              tooltip: '로그아웃',
              onPressed: _loading ? null : _logout, // 로딩 중이면 비활성화
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: _loading
              ? const CircularProgressIndicator() // 로딩중
              : _error != null
              ? Text(_error!) // 에러 메세지
              : _me == null
              ? const Text('데이터 없음')
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${_me!['id']}'),
                        const SizedBox(height: 8),
                        Text('이메일: ${_me!['email']}'),
                        const SizedBox(height: 8),
                        Text('닉네임: ${_me!['nickname']}'),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _loadMe,
                          child: const Text('새로고침'),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.tonal(
                          onPressed: _logout,
                          child: const Text('로그아웃'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
