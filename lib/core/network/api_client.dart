import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../data/dto/auth/auth_dtos.dart';
import '../config.dart';
import '../data/session_manager.dart';

const _retryHeader = 'Authorization-Retry';

Dio _baseDio({Duration timeout = const Duration(seconds: 30)}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: timeout,
      receiveTimeout: timeout,
      sendTimeout: timeout,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
  return dio;
}

LogInterceptor? _logging() => kDebugMode
    ? LogInterceptor(requestBody: true, responseBody: true, logPrint: (o) => debugPrint('$o'))
    : null;

/// The refresh call goes through its own client so it never trips the auth interceptors.
Dio createRefreshDio() {
  final dio = _baseDio();
  final log = _logging();
  if (log != null) dio.interceptors.add(log);
  return dio;
}

Dio createApiClient(SessionManager session, Dio refreshDio) {
  final dio = _baseDio();
  dio.interceptors.add(AuthInterceptor(session));
  dio.interceptors.add(TokenAuthenticator(session, refreshDio, dio));
  final log = _logging();
  if (log != null) dio.interceptors.add(log);
  return dio;
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._session);

  final SessionManager _session;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _session.accessToken();
    final isAuthCall = options.uri.path.contains('/auth/');
    if (token != null && !isAuthCall && options.headers[_retryHeader] == null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class TokenAuthenticator extends QueuedInterceptor {
  TokenAuthenticator(this._session, this._refreshDio, this._client);

  final SessionManager _session;
  final Dio _refreshDio;
  final Dio _client;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401) return handler.next(err);

    // avoid an infinite 401 loop
    if (request.headers[_retryHeader] != null) return handler.next(err);

    final current = _session.accessToken();
    final sent = (request.headers['Authorization'] as String?)?.replaceFirst('Bearer ', '');
    if (current != null && current != sent) {
      return _retry(request, current, err, handler);
    }

    final refreshToken = _session.refreshToken();
    if (refreshToken == null) {
      await _session.clear();
      return handler.next(err);
    }

    AuthResponse? body;
    try {
      final res = await _refreshDio.post<Map<String, dynamic>>(
        'auth/refresh',
        data: RefreshTokenRequest(refreshToken).toJson(),
      );
      if (res.data != null) body = AuthResponse.fromJson(res.data!);
    } catch (_) {
      body = null;
    }

    if (body != null && body.accessToken.trim().isNotEmpty) {
      await _session.updateToken(body.accessToken, body.refreshToken);
      return _retry(request, body.accessToken, err, handler);
    }

    await _session.clear();
    handler.next(err);
  }

  Future<void> _retry(
    RequestOptions request,
    String token,
    DioException original,
    ErrorInterceptorHandler handler,
  ) async {
    request.headers['Authorization'] = 'Bearer $token';
    request.headers[_retryHeader] = '1';
    try {
      handler.resolve(await _client.fetch(request));
    } on DioException catch (e) {
      handler.next(e);
    } catch (_) {
      handler.next(original);
    }
  }
}
