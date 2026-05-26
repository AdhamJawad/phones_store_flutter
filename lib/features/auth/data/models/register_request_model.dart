class RegisterRequestModel {
  const RegisterRequestModel({
    required this.name,
    required this.email,
    this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  final String name;
  final String email;
  final String? phone;
  final String password;
  final String passwordConfirmation;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      if (phone != null && phone!.trim().isNotEmpty) 'phone': phone!.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
