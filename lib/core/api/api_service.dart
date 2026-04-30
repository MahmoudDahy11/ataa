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
    Map<String, dynamic>? headers,
  }) async {
    return _dio.post(
      url,
      data: body,
      options: Options(contentType: contentType, headers: headers),
    );
  }

  Future<Response<dynamic>> get({
    required String url,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(url, queryParameters: queryParameters);
  }

  Future<Response<dynamic>> postJson({
    required String url,
    required Map<String, dynamic> body,
    Map<String, dynamic>? headers,
  }) {
    return _dio.post(
      url,
      data: body,
      options: Options(contentType: Headers.jsonContentType, headers: headers),
    );
  }

  Future<Response<dynamic>> putBytes({
    required String url,
    required List<int> bytes,
    required String mimeType,
    void Function(double progress)? onProgress,
  }) async {
    // We use a fresh Dio instance for external storage uploads to avoid
    // global interceptors (like AuthInterceptor) and headers (like ngrok-skip-browser-warning)
    // from interfering with the pre-signed URL signature.
    final uploadDio = Dio();
    return uploadDio.put(
      url,
      data: bytes,
      options: Options(
        headers: {
          Headers.contentTypeHeader: mimeType,
          Headers.contentLengthHeader: bytes.length,
        },
      ),
      onSendProgress: (sent, total) {
        if (total > 0 && onProgress != null) {
          onProgress(sent / total);
        }
      },
    );
  }
}
