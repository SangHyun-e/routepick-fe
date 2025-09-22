import 'package:dio/dio.dart';
import 'package:route_pick_fe/core/http/api_client.dart';
import 'package:route_pick_fe/features/auth/data/login_response.dart';
import 'package:flutter/foundation.dart';

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
    );

    // 디버깅 로그
    debugPrint('[AuthApi] /auth/login status= ${res.statusCode}');
    debugPrint('[AuthApi] /auth/login dataType= ${res.data.runtimeType}');
    debugPrint('[AuthApi] /auth/login data= ${res.data}');

    if (res.data is! Map) {
      throw FormatException('Unexpected body type: ${res.data.runtimeType}');
    }
    final map = Map<String, dynamic>.from(res.data as Map);
    return LoginResponse.fromJson(map);
  }
}
