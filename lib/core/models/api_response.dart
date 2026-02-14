class ApiResponse<T> {
  final T? data;
  final String? error;
  final bool success;
  final int? statusCode;
  final String? message;

  ApiResponse({
    this.data,
    this.error,
    required this.success,
    this.statusCode,
    this.message,
  });

  // Success factory
  factory ApiResponse.success({
    required T data,
    String? message,
    int statusCode = 200,
  }) {
    return ApiResponse(
      data: data,
      success: true,
      message: message,
      statusCode: statusCode,
    );
  }

  // Error factory
  factory ApiResponse.error({
    required String error,
    int statusCode = 500,
    String? message,
  }) {
    return ApiResponse(
      error: error,
      success: false,
      statusCode: statusCode,
      message: message,
    );
  }

  // Loading state
  factory ApiResponse.loading() {
    return ApiResponse(
      success: false,
      message: 'Loading...',
    );
  }

  // Check if response has data
  bool get hasData => data != null;

  // Check if response has error
  bool get hasError => error != null;

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'error': error,
      'success': success,
      'statusCode': statusCode,
      'message': message,
    };
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
      success: json['success'] ?? false,
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }
}
