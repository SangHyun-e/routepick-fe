class LoginResponseDto {
  final String accessToken;
  final int expiresIn;

  LoginResponseDto({required this.accessToken, required this.expiresIn});

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      accessToken: json['accessToken'] as String,
      expiresIn: (json['expiresIn'] as num).toInt(),
    );
  }
}
