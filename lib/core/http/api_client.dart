import 'package:dio/dio.dart';

import '../env/env.dart';
import 'with_credentials_io.dart'
    if (dart.library.html) 'with_credentials_web.dart';

Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
      headers: const {'Accept': 'application/json'},
    ),
  );

  // 웹에서 쿠키(리프레시 토큰) 포함되도록 설정
  configureWithCredentials(dio);

  return dio;
}

final Dio http = createDio();
