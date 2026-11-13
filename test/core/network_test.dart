import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messseat/core/data/session_manager.dart';
import 'package:messseat/core/network/api_client.dart';
import 'package:messseat/core/network/api_result.dart';
import 'package:messseat/core/network/safe_api_call.dart';
import 'package:messseat/core/network/stomp_client.dart';
import 'package:messseat/data/dto/auth/auth_dtos.dart';
import 'package:messseat/data/dto/user/user_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Handler = ResponseBody Function(RequestOptions options);

class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.handler);

  final Handler handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

DioException badResponse(int status, Object? data) {
  final options = RequestOptions(path: '/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  group('safeApiCall', () {
    test('wraps a successful value', () async {
      final r = await safeApiCall(() async => 42);
      expect(r, isA<ApiSuccess<int>>());
      expect((r as ApiSuccess<int>).data, 42);
    });

    test('prefers the first field error', () async {
      final r = await safeApiCall<int>(
        () => throw badResponse(400, {
          'code': 'VALIDATION',
          'message': 'Invalid',
          'fieldErrors': {'email': 'must be valid'},
        }),
      );
      final e = r as ApiError<int>;
      expect(e.message, 'email: must be valid');
      expect(e.code, 'VALIDATION');
      expect(e.status, 400);
    });

    test('uses the server message', () async {
      final r = await safeApiCall<int>(
        () => throw badResponse(409, {'message': 'Email already used'}),
      );
      final e = r as ApiError<int>;
      expect(e.message, 'Email already used');
      expect(e.code, isNull);
    });

    test('falls back when the body is empty or not json', () async {
      final empty = await safeApiCall<int>(() => throw badResponse(500, ''));
      expect((empty as ApiError).message, 'Something went wrong(500).');

      final html = await safeApiCall<int>(() => throw badResponse(502, '<html>'));
      expect((html as ApiError).message, 'Something went wrong(502).');

      final noMessage = await safeApiCall<int>(() => throw badResponse(404, {'code': 'X'}));
      expect((noMessage as ApiError).message, 'Request failed (404).');
    });

    test('reports connectivity problems', () async {
      final r = await safeApiCall<int>(
        () => throw DioException.connectionError(
          requestOptions: RequestOptions(path: '/'),
          reason: 'offline',
        ),
      );
      expect(
        (r as ApiError).message,
        'Cannot reach the server. Check your connection and try again.',
      );
    });
  });

  group('auth interceptors', () {
    late SessionManager session;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      session = SessionManager(await SharedPreferences.getInstance());
      await session.saveSession(
        const AuthResponse(
          accessToken: 'old',
          refreshToken: 'refresh-1',
          user: UserResponse(id: 1, roles: ['TENANT']),
        ),
      );
    });

    test('adds the bearer token except on auth endpoints', () async {
      final refresh = Dio();
      final client = createApiClient(session, refresh);
      final adapter = FakeAdapter((_) => json(200, {}));
      client.httpClientAdapter = adapter;

      await client.get<dynamic>('chats');
      await client.post<dynamic>('auth/login');

      expect(adapter.requests[0].headers['Authorization'], 'Bearer old');
      expect(adapter.requests[1].headers.containsKey('Authorization'), isFalse);
    });

    test('refreshes the token once on 401 and retries', () async {
      final refresh = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1/'));
      refresh.httpClientAdapter = FakeAdapter(
        (_) => json(200, {'accessToken': 'new', 'refreshToken': 'refresh-2'}),
      );
      final client = createApiClient(session, refresh);
      final adapter = FakeAdapter((o) {
        final auth = o.headers['Authorization'];
        return auth == 'Bearer new' ? json(200, {'ok': true}) : json(401, {});
      });
      client.httpClientAdapter = adapter;

      final res = await client.get<Map<String, dynamic>>('notifications');

      expect(res.data, {'ok': true});
      expect(session.accessToken(), 'new');
      expect(session.refreshToken(), 'refresh-2');
      expect(adapter.requests, hasLength(2));
    });

    test('clears the session when the refresh fails', () async {
      final refresh = Dio(BaseOptions(baseUrl: 'https://example.test/api/v1/'));
      refresh.httpClientAdapter = FakeAdapter((_) => json(401, {}));
      final client = createApiClient(session, refresh);
      client.httpClientAdapter = FakeAdapter((_) => json(401, {}));

      final r = await safeApiCall(() => client.get<dynamic>('notifications'));

      expect(r, isA<ApiError<dynamic>>());
      expect((r as ApiError).status, 401);
      expect(session.isLoggedIn, isFalse);
      expect(session.user, isNull);
    });
  });

  group('StompClient', () {
    test('derives the websocket url from the api base url', () {
      expect(
        StompClient.toWsUrl('https://basha-lagbe-backend.onrender.com/api/v1/'),
        'wss://basha-lagbe-backend.onrender.com/ws',
      );
      expect(
        StompClient.toWsUrl('http://192.168.0.132:8081/api/v1/'),
        'ws://192.168.0.132:8081/ws',
      );
    });

    test('extracts the frame body', () {
      const frame =
          'MESSAGE\ndestination:/topic/chats/1\ncontent-type:application/json\n\n{"id":1}\u0000';
      expect(StompClient.parseBody(frame), '{"id":1}');
      expect(StompClient.parseBody('CONNECTED\nversion:1.2'), '');
    });
  });
}
