import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.headers['ngrok-skip-browser-warning'] = 'true';
  }

  Future<Response<dynamic>> post({
    required String url,
    required String contentType,
    required Map<String, dynamic> body,
    required String token,
    Map<String, dynamic>? headers,
  }) async {
    final response = await _dio.post(
      url,
      data: body,
      options: Options(
        contentType: contentType,
        headers: {'Authorization': 'Bearer $token', ...?headers},
      ),
    );
    return response;
  }

  Future<Response<dynamic>> get({
    required String url,
    required String token,
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get(
      url,
      queryParameters: queryParameters,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return response;
  }

  Future<Response<dynamic>> postJson({
    required String url,
    required Map<String, dynamic> body,
    String? token,
    Map<String, dynamic>? headers,
  }) {
    return _dio.post(
      url,
      data: body,
      options: Options(
        contentType: Headers.jsonContentType,
        headers: {
          if (token != null && token.isNotEmpty)
            'Authorization': 'Bearer $token',
          ...?headers,
        },
      ),
    );
  }

  Future<Response<dynamic>> putBytes({
    required String url,
    required List<int> bytes,
    required String contentType,
    Map<String, dynamic>? headers,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final response = await _dio.put(
      url,
      data: bytes,
      onSendProgress: onSendProgress,
      options: Options(contentType: contentType, headers: headers),
    );
    return response;
  }
}
