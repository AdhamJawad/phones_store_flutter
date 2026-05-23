class OrderParty {
  const OrderParty({
    required this.id,
    required this.name,
    this.username,
    this.phone,
    this.location,
  });

  final int id;
  final String name;
  final String? username;
  final String? phone;
  final String? location;
}
