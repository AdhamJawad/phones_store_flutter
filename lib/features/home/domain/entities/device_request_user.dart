class DeviceRequestUser {
  const DeviceRequestUser({
    required this.id,
    required this.name,
    this.username,
  });

  final int id;
  final String name;
  final String? username;
}
