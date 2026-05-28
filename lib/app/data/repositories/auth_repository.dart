// lib/app/data/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import '../constants/api_url.dart';
import '../exceptions/app_exception.dart';
import '../providers/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  /// Melakukan login ke server
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiUrl.login,
        data: {
          'email': email,
          'password': password,
          'platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw UnexpectedException(message: 'Login gagal');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 404) {
        throw ValidationException(message: 'Email atau password salah');
      }
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Melakukan logout dari server
  Future<void> logout(String userId) async {
    try {
      final response = await _apiClient.dio.post(
        ApiUrl.logout(userId),
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Logout gagal');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
