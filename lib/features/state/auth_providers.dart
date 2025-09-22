import 'package:flutter_riverpod/legacy.dart';

final accessTokenProvider = StateProvider<String?>((ref) => null);
final isLoggedInProvider = StateProvider<bool>((ref) => false);
