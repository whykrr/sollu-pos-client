import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../services/secure_storage_service.dart';

class DioClient {
  late final Dio dio;
  
  // As per user request, we use the specific API base url
  static const String baseUrl = 'http://dashboard.sollu.test/api/pos';

  DioClient(SecureStorageService secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorage));
    
    // Add logging interceptor for development (optional)
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }
}
