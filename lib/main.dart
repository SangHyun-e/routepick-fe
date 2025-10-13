import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

// 웹/비웹 분기
import 'core/web/url_strategy_stub.dart'
    if (dart.library.html) 'core/web/url_strategy_web.dart';

void main() {
  setUrlStrategy();
  runApp(const ProviderScope(child: App()));
}
