import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;

  ApiService({Dio? dio}) : _dio = dio ?? Dio();

  Future<Response> post({
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

  Future<Response> get({
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
}
