import 'auth_user_model.dart';

class CurrentUserResponseModel {
  const CurrentUserResponseModel({
    required this.user,
  });

  final AuthUserModel user;

  factory CurrentUserResponseModel.fromJson(Map<String, dynamic> json) {
    return CurrentUserResponseModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
