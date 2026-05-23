enum RechargeRequestStatus {
  pending,
  approved,
  rejected,
  unknown;

  static RechargeRequestStatus fromApi(String value) {
    return switch (value) {
      'pending' => RechargeRequestStatus.pending,
      'approved' => RechargeRequestStatus.approved,
      'rejected' => RechargeRequestStatus.rejected,
      _ => RechargeRequestStatus.unknown,
    };
  }
}
