import '../../domain/entities/order_party.dart';

class OrderPartyModel extends OrderParty {
  const OrderPartyModel({
    required super.id,
    required super.name,
    super.username,
    super.phone,
    super.location,
  });

  factory OrderPartyModel.fromJson(Map<String, dynamic> json) {
    return OrderPartyModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      username: json['username'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
    );
  }
}
