// lib/app/data/providers/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/routes/app_pages.dart';
import '../../services/auth_service.dart';
import '../constants/api_url.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late final Dio dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiUrl.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json', 'x-platform': 'mobile'},
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthService.to.token.value;
          if (token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (kDebugMode) {
            print('--> ${options.method} ${options.path}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Data: ${options.data}');
            }
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('<-- ${response.statusCode} ${response.requestOptions.path}');
            print('Response: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          if (kDebugMode) {
            print(
              '<-- ERROR ${error.response?.statusCode} ${error.requestOptions.path}',
            );
            print('Message: ${error.message}');
            if (error.response?.data != null) {
              print('Response Error: ${error.response?.data}');
            }
          }

          // Handle automatic session expiration
          if (error.response?.statusCode == 401) {
            AuthService.to.logout();
            if (Get.currentRoute != Routes.LOGIN) {
              Get.offAllNamed(Routes.LOGIN);
            }
          }
          return handler.next(error);
        },
      ),
    );
  }
}
