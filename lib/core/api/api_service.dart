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
  /*
  * This method is used to upload files as bytes to the server.
  * It takes the URL, the file bytes, content type, optional headers, and a callback for tracking upload progress.
  * The content type should be set according to the file type being uploaded (e.g., 'image/jpeg' for JPEG images).
  * The onSendProgress callback provides the number of bytes sent and the total bytes to be sent, allowing you to implement a progress indicator in the UI.
  */
  Future<Response> putBytes({
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
      options: Options(
        contentType: contentType,
        headers: headers,
      ),
    );
    return response;
  }
}
