import 'package:dio/dio.dart';
import '../auth/auth_token_provider.dart';

class AuthInterceptor extends Interceptor {
  final AuthTokenProvider _tokenProvider;
  const AuthInterceptor(this._tokenProvider);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _tokenProvider.getIdToken();
      options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    } catch (e) {
      // If token retrieval fails, we still proceed, but the request might fail later with 401
      // Alternatively, we could fail the request here.
      handler.next(options);
    }
  }
}
