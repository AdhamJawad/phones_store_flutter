enum RechargeMethod {
  syriatelCash,
  mtnCash,
  stripe;

  String get apiValue => switch (this) {
        RechargeMethod.syriatelCash => 'syriatel_cash',
        RechargeMethod.mtnCash => 'mtn_cash',
        RechargeMethod.stripe => 'stripe',
      };

  static RechargeMethod fromApi(String value) {
    return switch (value) {
      'syriatel_cash' => RechargeMethod.syriatelCash,
      'mtn_cash' => RechargeMethod.mtnCash,
      _ => RechargeMethod.stripe,
    };
  }
}
