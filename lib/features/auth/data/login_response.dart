/// /auth/login 응답 바디 { accessToken, expiresIn } 매핑용
class LoginResponse {
  final String accessToken;
  final int expiresIn;

  const LoginResponse({required this.accessToken, required this.expiresIn});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final token = json['accessToken'];
    final exp = json['expiresIn'];

    if (token is! String) {
      throw FormatException('accessToken is not String: ${token.runtimeType}');
    }
    final intExp = switch (exp) {
      int v => v,
      num v => v.toInt(),
      _ => throw FormatException('expiresIn is not num: ${exp.runtimeType}'),
    };

    return LoginResponse(accessToken: token, expiresIn: intExp);
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'expiresIn': expiresIn,
  };
}
