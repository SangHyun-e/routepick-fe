import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 인증 상태(임시): 추후 실제 로그인 로직 연결
final authStatusProvider = StateProvider<bool>((ref) => false);
