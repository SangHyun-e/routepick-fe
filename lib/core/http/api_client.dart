import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:route_pick_fe/core/env/env.dart';

final Dio http = (() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      headers: const {'Accept': 'application/json'},
    ),
  );

  // 웹에서 리프레시 쿠키를 오가게 하려면 withCredentials: true 필요
  if (kIsWeb) {
    dio.httpClientAdapter = BrowserHttpClientAdapter()..withCredentials;
  }

  return dio;
})();
