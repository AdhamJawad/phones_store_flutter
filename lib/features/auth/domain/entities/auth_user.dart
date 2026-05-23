class AuthUser {
  const AuthUser({
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
}
