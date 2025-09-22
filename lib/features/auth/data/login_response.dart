/// /auth/login 응답 바디 { accessToken, expiresIn } 매핑용
class LoginResponse {
  final String accessToken;
  final int expiresIn;

  const LoginResponse({required this.accessToken, required this.expiresIn});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: (json['accessToken'] as String?) ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
    );
  }
}
