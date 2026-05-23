enum WalletTransactionType {
  deposit,
  withdraw,
  credit,
  unknown;

  static WalletTransactionType fromApi(String value) {
    return switch (value) {
      'deposit' => WalletTransactionType.deposit,
      'withdraw' => WalletTransactionType.withdraw,
      'credit' => WalletTransactionType.credit,
      _ => WalletTransactionType.unknown,
    };
  }
}
