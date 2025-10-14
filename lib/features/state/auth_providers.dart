import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:route_pick_fe/core/storage/token_storage.dart';
import 'package:route_pick_fe/features/auth/data/auth_api.dart';

/// 전역 인증 상태: access_token (null이면 로그아웃 상태)
final accessTokenProvider = StateProvider<String?>((ref) => null);

/// TokenStorage 구현체를 DI
final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// 1) 앱 시작 시 디스크에서 토큰 읽어 메모리에 넣기
final authBootstrapProvider = FutureProvider<void>((ref) async {
  final saved = await ref.read(tokenStorageProvider).load(); // ✅ load 사용
  ref.read(accessTokenProvider.notifier).state =
      (saved != null && saved.isNotEmpty) ? saved : null;
});

/// 2) 내 정보 캐시
final meProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final token = ref.watch(accessTokenProvider);
  if (token == null) return null;
  final api = AuthApi();
  return api.me(accessToken: token);
});

/// 3) GoRouter 갱신용 ChangeNotifier
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen<String?>(accessTokenProvider, (_, __) => notifyListeners());
    ref.listen<AsyncValue<void>>(
      authBootstrapProvider,
      (_, __) => notifyListeners(),
    );
  }
  final Ref ref;

  String? get token => ref.read(accessTokenProvider);
  bool get bootstrapped => ref.read(authBootstrapProvider).hasValue;
}

final routerNotifierProvider = Provider<RouterNotifier>(
  (ref) => RouterNotifier(ref),
);
