import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:route_pick_fe/features/auth/data/auth_api.dart';
import 'package:route_pick_fe/features/state/auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _submitting = false;

  final _api = AuthApi();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    try {
      final res = await _api.login(
        email: _email.text.trim(),
        password: _password.text,
      );

      debugPrint(
        '[LoginPage] login OK: token len=${res.accessToken.length}, exp=${res.expiresIn}',
      );

      // 토큰 저장
      ref.read(accessTokenProvider.notifier).state = res.accessToken;

      if (!mounted) return;

      // from 쿼리 있으면 거기로, 없으면 홈으로 이동
      final from = GoRouterState.of(context).uri.queryParameters['from'];
      context.go(from ?? '/');
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] is String)
          ? data['message'] as String
          : '로그인에 실패했습니다: ${e.message}';
      debugPrint(
        'LoginPage] DioException type= ${e.type}, status=${e.response?.statusCode} data=$data',
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('알 수 없는 오류: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return '이메일을 입력해주세요';
    if (!v.contains('@')) return '이메일 형식이 아닙니다';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return '비밀번호를 입력해주세요';
    if (v.length < 8) return '비밀번호는 8자 이상이어야 합니다';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 이메일
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                      labelText: '이메일',
                      hintText: 'you@example.com',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.username,
                      AutofillHints.email,
                    ],
                    validator: _validateEmail,
                    enabled: !_submitting,
                  ),
                  const SizedBox(height: 12),
                  // 비밀번호
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(labelText: '비밀번호'),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: _validatePassword,
                    enabled: !_submitting,
                  ),
                  const SizedBox(height: 20),
                  // 로그인 버튼
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('로그인'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => GoRouter.of(context).go('/'),
                    child: Text('홈으로', style: theme.textTheme.bodyMedium),
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
