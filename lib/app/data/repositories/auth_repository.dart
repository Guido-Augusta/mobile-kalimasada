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
        data: {'email': email, 'password': password, 'platform': 'mobile'},
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
      final response = await _apiClient.dio.post(ApiUrl.logout(userId));

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Logout gagal');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> verifyOldPassword(String oldPassword) async {
    try {
      final response = await _apiClient.dio.post(
        ApiUrl.verifyOldPassword,
        data: {'oldPassword': oldPassword},
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Verifikasi gagal');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _apiClient.dio.post(
        ApiUrl.changePassword,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Gagal mengubah password');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      final response = await _apiClient.dio.post(
        ApiUrl.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Gagal mengirim token');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> verifyToken(String token) async {
    try {
      final response = await _apiClient.dio.post(
        ApiUrl.verifyToken,
        data: {'token': token},
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Gagal diverifikasi');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _apiClient.dio.post(
        ApiUrl.resetPassword,
        data: {'token': token, 'newPassword': newPassword},
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Gagal mengubah password');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> checkAuth(String role, String roleId) async {
    try {
      Response response;
      if (role == 'santri') {
        response = await _apiClient.dio.get(ApiUrl.santriDetail(roleId));
      } else if (role == 'ustadz') {
        response = await _apiClient.dio.get(ApiUrl.ustadzDetail(roleId));
      } else if (role == 'ortu') {
        response = await _apiClient.dio.get(ApiUrl.ortuDetail(roleId));
      } else if (role == 'admin') {
        response = await _apiClient.dio.get(
          ApiUrl.santriRank,
          queryParameters: {'page': 1, 'limit': 1, 'tahapHafalan': 'level1'},
        );
      } else {
        throw UnexpectedException(message: 'Role tidak dikenali');
      }

      if (response.statusCode != 200) {
        throw UnexpectedException(
          message: 'Gagal memuat data\nSilakan login kembali',
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ValidationException(
          message: 'Token tidak valid\nSilakan login kembali',
        );
      }
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
