import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:route_pick_fe/app/app.dart';

// 전역 Dio 초기화
import 'core/http/api_client.dart' as api_client;

// 웹에서만 path 전략 사용 (비웹/테스트는 no-op)
import 'core/web/url_strategy_stub.dart'
    if (dart.library.html) 'core/web/url_strategy_web.dart';

void main() {
  setUrlStrategy(); // 웹: path, 비웹: 그대로
  api_client.initHttp(); // 여기서 withCredentials 적용됨(웹일 때)
  runApp(const ProviderScope(child: App()));
}
