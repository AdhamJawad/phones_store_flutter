enum OrderPaymentMethod {
  wallet,
  stripe,
  cod;

  String get apiValue => name;
}
