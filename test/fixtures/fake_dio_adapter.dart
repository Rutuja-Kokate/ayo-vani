import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';

/// Reusable fake HttpClientAdapter for testing Dio network calls.
class FakeDioAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  FakeDioAdapter(this.handler);

  factory FakeDioAdapter.jsonResponse({
    int statusCode = 200,
    Map<String, dynamic> data = const {'status': 'ok'},
  }) {
    return FakeDioAdapter((options) async {
      final jsonStr = jsonEncode(data);
      return ResponseBody.fromString(
        jsonStr,
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
  }

  factory FakeDioAdapter.serverError({
    int statusCode = 500,
    String error = 'Internal Server Error',
  }) {
    return FakeDioAdapter((options) async {
      return ResponseBody.fromString(
        jsonEncode({'error': error}),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    });
  }

  factory FakeDioAdapter.timeout() {
    return FakeDioAdapter((options) async {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timed out',
      );
    });
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}
