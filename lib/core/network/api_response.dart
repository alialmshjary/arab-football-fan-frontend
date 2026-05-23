class ApiResponse<T> {
  const ApiResponse({
    required this.isSuccess,
    required this.message,
    this.data,
    this.statusCode,
    this.errors = const [],
  });

  final bool isSuccess;
  final String message;
  final T? data;
  final int? statusCode;
  final List<dynamic> errors;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? decoder,
    int fallbackStatusCode,
  ) {
    final rawData = json['data'] ?? json['Data'];
    final dynamic rawStatus = json['statusCode'] ?? json['StatusCode'];
    final int? parsedStatus = rawStatus is int ? rawStatus : int.tryParse('$rawStatus');
    final errorsValue = json['errors'] ?? json['Errors'];

    return ApiResponse<T>(
      isSuccess: (json['isSuccess'] ?? json['IsSuccess']) == true,
      message: (json['message'] ?? json['Message'] ?? '').toString(),
      data: rawData == null || decoder == null ? rawData as T? : decoder(rawData),
      statusCode: parsedStatus ?? fallbackStatusCode,
      errors: errorsValue is List ? errorsValue : const [],
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
