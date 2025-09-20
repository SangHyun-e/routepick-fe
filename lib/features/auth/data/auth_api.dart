import 'package:dio/dio.dart';
import 'package:route_pick_fe/core/http/api_client.dart';
import 'package:route_pick_fe/features/auth/data/login_response.dart';

class AuthApi {
  // POST /auth/login
  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    try {
      final resp = await http.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return LoginResponseDto.fromJson(resp.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = e.response?.data?.toString() ?? e.message;
      throw Exception('Login failed ($code): $msg');
    }
  }
}
