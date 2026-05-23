class ApiErrorResponse {
  const ApiErrorResponse({
    required this.message,
    required this.code,
    this.errors = const <String, List<String>>{},
  });

  final String message;
  final String code;
  final Map<String, List<String>> errors;

  factory ApiErrorResponse.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];
    return ApiErrorResponse(
      message: json['message'] as String? ?? '',
      code: json['code'] as String? ?? 'ERROR',
      errors: rawErrors is Map
          ? rawErrors.map(
              (key, value) => MapEntry(
                key.toString(),
                (value as List<dynamic>).map((item) => item.toString()).toList(),
              ),
            )
          : const <String, List<String>>{},
    );
  }
}
