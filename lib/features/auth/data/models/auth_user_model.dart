import '../../domain/entities/auth_user.dart';

class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.username,
    this.phone,
    this.role,
    this.walletBalance,
    this.location,
  });

  final int id;
  final String name;
  final String email;
  final String? username;
  final String? phone;
  final String? role;
  final double? walletBalance;
  final String? location;

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      walletBalance: (json['wallet_balance'] as num?)?.toDouble(),
      location: json['location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'phone': phone,
      'role': role,
      'wallet_balance': walletBalance,
      'location': location,
    };
  }

  AuthUser toEntity() {
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
