import 'dart:convert';

import 'package:dio/dio.dart';

import 'api_result.dart';

Future<ApiResult<T>> safeApiCall<T>(Future<T> Function() block) async {
  try {
    return ApiSuccess(await block());
  } on DioException catch (e) {
    final response = e.response;
    if (e.type == DioExceptionType.badResponse && response != null) {
      final (message, code) = _parseError(response);
      return ApiError(message, code: code, status: response.statusCode);
    }
    if (e.type == DioExceptionType.cancel) {
      return ApiError(e.message ?? 'Request cancelled.');
    }
    return const ApiError('Cannot reach the server. Check your connection and try again.');
  } catch (e) {
    final text = e.toString();
    return ApiError(text.isEmpty ? 'Something went wrong. Please try again.' : text);
  }
}

(String, String?) _parseError(Response<dynamic> response) {
  final status = response.statusCode;
  var body = response.data;
  if (body == null || (body is String && body.trim().isEmpty)) {
    return ('Something went wrong($status).', null);
  }
  try {
    if (body is String) body = jsonDecode(body);
    if (body is! Map) return ('Something went wrong($status).', null);

    final rawCode = body['code']?.toString();
    final code = (rawCode == null || rawCode.trim().isEmpty) ? null : rawCode;

    final fieldErrors = body['fieldErrors'];
    if (fieldErrors is Map && fieldErrors.isNotEmpty) {
      final key = fieldErrors.keys.first;
      return ('$key: ${fieldErrors[key]}', code);
    }

    final message = body['message']?.toString() ?? '';
    return (message.trim().isEmpty ? 'Request failed ($status).' : message, code);
  } catch (_) {
    return ('Something went wrong($status).', null);
  }
}
