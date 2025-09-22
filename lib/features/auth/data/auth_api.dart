import 'package:dio/dio.dart';
import 'package:route_pick_fe/core/http/api_client.dart';
import 'package:route_pick_fe/features/auth/data/login_response.dart';
import 'package:flutter/foundation.dart';

// 백엔드 Auth 관련 호출을 모은 간단한 API 래퍼
class AuthApi {
  // _dio: 실제 요청에 사용할 Dio 인스턴스
  final Dio _dio;

  // 기본은 전역 http(Dio), 테스트 등에서는 주입 가능하도록 선택 인자 허용
  AuthApi({Dio? dio}) : _dio = dio ?? http;

  // POST /auth/login
  // - body: {email, password}
  // - response body: {accessToken, expiresIn}
  Future<LoginResponse> login({
    required String email,
    required String password,
  }) async {
    // Dio.post: HTTP POST 요청
    final Response res = await _dio.post(
      '/auth/login', // baseUrl + 이 path
      data: {'email': email, 'password': password}, // JSON 바디
    );

    // 디버깅 로그
    debugPrint('[AuthApi] /auth/login status= ${res.statusCode}');
    debugPrint('[AuthApi] /auth/login dataType= ${res.data.runtimeType}');
    debugPrint('[AuthApi] /auth/login data= ${res.data}');

    // 상태 코드 200 and JSON Map 아니면 예외 발생
    if (res.data is! Map) {
      throw FormatException('Unexpected body type: ${res.data.runtimeType}');
    }
    return LoginResponse.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // GET /users/me
  // - Authorization: Bearer <accessToken>
  // - response 예시: {"id": 1, "email": "...", "name": "..."}
  Future<Map<String, dynamic>> me({required String accessToken}) async {
    final Response res = await _dio.get(
      '/users/me',
      options: Options(
        headers: {
          // 백엔드에서 읽는 표준 인증 헤더
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );
    if (res.data is! Map) {
      throw FormatException('Unexpected body type: ${res.data.runtimeType}');
    }
    // 간단히 Map 으로 반환 (나중에 DTO로 뽑아도 됨)
    return Map<String, dynamic>.from(res.data as Map);
  }

  // POST /auth/logout
  // - Authorization: Bearer <accessToken> (서버가 access 블랙리스트 등록)
  // - refresh 쿠키는 서버가 Set-Cookie(빈값/만료)로 제거 (웹에선 withCredentials= true 필수)
  Future<void> logout({required String accessToken}) async {
    await _dio.post(
      '/auth/logout',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
  }
}
