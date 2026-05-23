import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../storage/storage_service.dart';
import 'api_response.dart';

class ApiClient {
  ApiClient({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 25);

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(ApiConstants.baseUrl);
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return base.replace(
      path: cleanPath,
      queryParameters: query?.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, String> _headers({bool hasJsonBody = true}) {
    final token = StorageService.token;
    return {
      'Accept': 'application/json',
      if (hasJsonBody) 'Content-Type': 'application/json; charset=utf-8',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic json)? decoder,
  }) async {
    return _safeRequest(
      () => _client.get(_uri(path, query), headers: _headers()).timeout(_timeout),
      decoder,
    );
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? decoder,
  }) async {
    return _safeRequest(
      () => _client
          .post(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body))
          .timeout(_timeout),
      decoder,
    );
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? decoder,
  }) async {
    return _safeRequest(
      () => _client
          .put(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body))
          .timeout(_timeout),
      decoder,
    );
  }

  Future<ApiResponse<T>> patch<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? decoder,
  }) async {
    return _safeRequest(
      () => _client
          .patch(_uri(path), headers: _headers(), body: body == null ? null : jsonEncode(body))
          .timeout(_timeout),
      decoder,
    );
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    T Function(dynamic json)? decoder,
  }) async {
    return _safeRequest(
      () => _client.delete(_uri(path), headers: _headers()).timeout(_timeout),
      decoder,
    );
  }

  Future<ApiResponse<T>> multipart<T>(
    String path, {
    String method = 'POST',
    Map<String, String> fields = const {},
    List<http.MultipartFile> files = const [],
    T Function(dynamic json)? decoder,
  }) async {
    try {
      final request = http.MultipartRequest(method, _uri(path));
      request.headers.addAll(_headers(hasJsonBody: false));
      request.fields.addAll(fields);
      request.files.addAll(files);
      final streamed = await request.send().timeout(const Duration(seconds: 35));
      final response = await http.Response.fromStream(streamed);
      return _parseResponse<T>(response, decoder);
    } on TimeoutException {
      throw const ApiException('انتهت مهلة الاتصال بالخادم. تحقق من تشغيل الباك اند.');
    } catch (_) {
      throw const ApiException('تعذر رفع البيانات. تحقق من الاتصال وعنوان API_BASE_URL.');
    }
  }

  Future<ApiResponse<T>> _safeRequest<T>(
    Future<http.Response> Function() request,
    T Function(dynamic json)? decoder,
  ) async {
    try {
      final response = await request();
      return _parseResponse<T>(response, decoder);
    } on TimeoutException {
      throw const ApiException('انتهت مهلة الاتصال بالخادم. تحقق من تشغيل الباك اند.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('تعذر الاتصال بالخادم. تحقق من عنوان API_BASE_URL ومن تشغيل الباك اند.');
    }
  }

  ApiResponse<T> _parseResponse<T>(http.Response response, T Function(dynamic json)? decoder) {
    final decoded = _decode(response);
    final statusOk = response.statusCode >= 200 && response.statusCode < 300;

    if (decoded is Map<String, dynamic>) {
      final apiResponse = ApiResponse<T>.fromJson(decoded, decoder, response.statusCode);
      if (!statusOk || !apiResponse.isSuccess) {
        throw ApiException(_messageFrom(apiResponse, response.statusCode), statusCode: response.statusCode);
      }
      return apiResponse;
    }

    if (!statusOk) {
      throw ApiException('فشل الطلب. رمز الحالة: ${response.statusCode}', statusCode: response.statusCode);
    }

    return ApiResponse<T>(
      isSuccess: true,
      message: 'تمت العملية بنجاح',
      data: decoded == null || decoder == null ? decoded as T? : decoder(decoded),
      statusCode: response.statusCode,
    );
  }

  dynamic _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  String _messageFrom(ApiResponse<dynamic> response, int statusCode) {
    if (response.message.trim().isNotEmpty) return response.message;
    if (response.errors.isNotEmpty) return response.errors.join('\n');
    if (statusCode == 401) return 'انتهت الجلسة، سجل الدخول مرة أخرى.';
    if (statusCode == 403) return 'لا تملك صلاحية تنفيذ هذه العملية.';
    return 'تعذر تنفيذ الطلب. حاول مرة أخرى.';
  }

  static String mediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final normalized = path.startsWith('/') ? path : '/$path';
    return '${ApiConstants.baseUrl}$normalized';
  }
}
