import '../../domain/entities/auth_session.dart';
import 'auth_user_model.dart';

class AuthSessionModel {
  const AuthSessionModel({
    required this.token,
    required this.tokenType,
    required this.user,
  });

  final String token;
  final String tokenType;
  final AuthUserModel user;

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    return AuthSessionModel(
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }

  AuthSession toEntity() {
    return AuthSession(
      token: token,
      tokenType: tokenType,
      user: user.toEntity(),
    );
  }
}
