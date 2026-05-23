import '../../../auth/data/models/auth_user_model.dart';
import '../../domain/entities/profile_user.dart';

class ProfileUserModel extends ProfileUser {
  const ProfileUserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.walletBalance,
    super.username,
    super.phone,
    super.gender,
    super.dateOfBirth,
    super.location,
    super.status,
    super.role,
    super.emailVerifiedAt,
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      location: json['location'] as String?,
      status: json['status'] as String?,
      role: json['role'] as String?,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble() ?? 0,
      emailVerifiedAt:
          DateTime.tryParse(json['email_verified_at'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
    );
  }

  AuthUserModel toAuthUserModel() {
    return AuthUserModel(
      id: id,
      name: name,
      email: email,
      username: username,
      phone: phone,
      role: role,
      walletBalance: walletBalance,
      location: location,
    );
  }
}
