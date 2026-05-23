enum OrderStatus {
  pending,
  approved,
  rejected,
  shipping,
  completed,
  cancelled,
  unknown;

  static OrderStatus fromApi(String value) {
    return switch (value) {
      'pending' => OrderStatus.pending,
      'approved' => OrderStatus.approved,
      'rejected' => OrderStatus.rejected,
      'shipping' => OrderStatus.shipping,
      'completed' => OrderStatus.completed,
      'cancelled' => OrderStatus.cancelled,
      _ => OrderStatus.unknown,
    };
  }
}
