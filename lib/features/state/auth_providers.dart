import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:route_pick_fe/core/storage/token_storage.dart';

// 전역 인증 상태: access_token (null이면 로그아웃 상태)
final accessTokenProvider = StateProvider<String?>((ref) => null);

// DI: TokenStorage
final tokenStorageProvider = Provider<TokenStorage>((_) => TokenStorage());

// 앱 시작 시 디스크에서 토큰을 읽어와 accessTokenProvider 세팅
final bootProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(tokenStorageProvider);
  final token = await storage.load();
  ref.read(accessTokenProvider.notifier).state = token;
});
