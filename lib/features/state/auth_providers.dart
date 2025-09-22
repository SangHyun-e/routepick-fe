import 'package:flutter_riverpod/legacy.dart';

// 전역 인증 상태: access_token (null이면 로그아웃 상태)
final accessTokenProvider = StateProvider<String?>((ref) => null);
