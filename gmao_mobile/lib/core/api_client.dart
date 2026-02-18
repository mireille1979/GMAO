import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  final Dio _dio = Dio();
  // IMPORTANT: For Android Emulator use 10.0.2.2. For Physical Device use PC IP.
  // For Web use localhost.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8081/api'; // Use 127.0.0.1 to avoid CORS mixed content with debug server
    }
    return 'http://10.0.2.2:8081/api';
  } 

  ApiClient() {
    print('DEBUG API CLIENT: Connecting to baseUrl: $baseUrl');
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Do not send token for auth endpoints
        if (!options.path.contains('/auth/')) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        return handler.next(options);
      },
    ));
    
    // Add LogInterceptor for better debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }

  Dio get dio => _dio;
}
