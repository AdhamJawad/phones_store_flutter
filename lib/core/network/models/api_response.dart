class ApiResponse<T> {
  const ApiResponse({
    required this.message,
    this.data,
    this.meta,
  });

  final T? data;
  final String message;
  final Map<String, dynamic>? meta;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json.containsKey('data') ? fromJsonT(json['data']) : null,
      message: json['message'] as String? ?? '',
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : json['meta'] is Map
              ? Map<String, dynamic>.from(json['meta'] as Map)
              : null,
    );
  }
}
