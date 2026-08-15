import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';
import '../services/secure_storage_service.dart';

class DioClient {
  late final Dio dio;
  
  static String get baseUrl => AppConfig.apiBaseUrl;

  DioClient(SecureStorageService secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: AppConfig.connectTimeoutSeconds),
        receiveTimeout: Duration(seconds: AppConfig.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(secureStorage));
    
    // Add logging interceptor if enabled in configuration
    if (AppConfig.enableLogging) {
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
}
