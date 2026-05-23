class CreateRechargeRequestInput {
  const CreateRechargeRequestInput({
    required this.amount,
    required this.method,
    this.proofFilePath,
  });

  final double amount;
  final String method;
  final String? proofFilePath;
}
