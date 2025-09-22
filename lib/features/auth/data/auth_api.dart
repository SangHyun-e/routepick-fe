import 'package:dio/dio.dart';
import 'package:route_pick_fe/core/http/api_client.dart';
import 'package:route_pick_fe/features/auth/data/login_response.dart';

class AuthApi {
  final Dio _dio;
  AuthApi({Dio? dio}) : _dio = dio ?? http;

  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    final Response res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
      options: Options(responseType: ResponseType.json),
    );

    // 웹에서 타입이 dynamic일 수 있으니 안전 변환
    final Map<String, dynamic> body = res.data is Map
        ? Map<String, dynamic>.from(res.data as Map)
        : <String, dynamic>{};

    return LoginResponse.fromJson(body);
  }
}
