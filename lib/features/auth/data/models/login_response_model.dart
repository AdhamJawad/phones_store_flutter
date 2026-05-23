import 'auth_session_model.dart';
import 'auth_user_model.dart';

class LoginResponseModel {
  const LoginResponseModel({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final AuthUserModel user;

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthSessionModel toSessionModel() {
    return AuthSessionModel(
      token: token,
      tokenType: tokenType,
      user: user,
    );
  }
}
