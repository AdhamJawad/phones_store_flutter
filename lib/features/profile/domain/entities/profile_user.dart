import '../../../auth/domain/entities/auth_user.dart';

class ProfileUser {
  const ProfileUser({
    required this.id,
    required this.name,
    required this.email,
    required this.walletBalance,
    this.username,
    this.phone,
    this.gender,
    this.dateOfBirth,
    this.location,
    this.status,
    this.role,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? gender;
  final String? dateOfBirth;
  final String? location;
  final String? status;
  final String? role;
  final double walletBalance;
  final DateTime? emailVerifiedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AuthUser toAuthUser() {
    return AuthUser(
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
