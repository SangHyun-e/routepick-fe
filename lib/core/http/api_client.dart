import 'package:dio/dio.dart';
import 'package:route_pick_fe/core/env/env.dart';

// 웹/비웹에 따라 다른 구현을 선택적으로 불러온다.
import 'with_credentials_io.dart'
    if (dart.library.html) 'with_credentials_web.dart';

// 앱 전역에서 쓰는 Dio 인스턴스
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

  configureWithCredentials(dio);
  return dio;
})();
