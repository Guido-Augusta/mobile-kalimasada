// lib/app/data/repositories/ortu_repository.dart
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_url.dart';
import '../exceptions/app_exception.dart';
import '../models/daftar_santri.dart';
import '../models/ortu.dart';
import '../models/santri.dart' as s;
import '../providers/api_client.dart';

class OrtuRepository {
  final ApiClient _apiClient = ApiClient();

  /// Mengambil detail orang tua berdasarkan ortuId
  Future<Ortu> getOrtuDetail(String ortuId) async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.ortuDetail(ortuId));

      if (response.statusCode == 200) {
        final responseData = response.data;
        return Ortu.fromJson(responseData['data']);
      } else {
        throw UnexpectedException(
          message: 'Gagal memuat data profil orang tua',
        );
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Mengambil daftar santri (anak) berdasarkan ortuId
  Future<List<Datum>> getSantriList(String ortuId) async {
    try {
      final queryParams = {'page': '1', 'limit': '10', 'ortuId': ortuId};

      final response = await _apiClient.dio.get(
        ApiUrl.santri,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return List<Datum>.from(
          responseData['data'].map((x) => Datum.fromJson(x)),
        );
      } else {
        throw UnexpectedException(message: 'Gagal memuat daftar anak');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Mengambil daftar santri (anak) untuk home page dengan pencarian dan pagination
  Future<List<s.Santri>> getChildrenList({
    required String ortuId,
    required int page,
    required int limit,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'ortuId': ortuId,
        if (search != null && search.trim().isNotEmpty) 'search': search,
      };

      final response = await _apiClient.dio.get(
        ApiUrl.santri,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return List<s.Santri>.from(
          responseData['data'].map((x) => s.Santri.fromJson(x)),
        );
      } else {
        throw UnexpectedException(message: 'Gagal memuat daftar anak');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Memperbarui data profil orang tua
  Future<Ortu> updateProfile({
    required String ortuId,
    required String nama,
    required String noHp,
    required String alamat,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiUrl.ortuDetail(ortuId),
        data: {
          'nama': nama,
          'nomorHp': noHp,
          'alamat': alamat,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return Ortu.fromJson(responseData['data']);
      } else {
        throw UnexpectedException(message: 'Gagal memperbarui profil');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Mengunggah foto profil orang tua
  Future<Ortu> uploadFotoProfil({
    required String ortuId,
    required List<int> bytes,
    required String fileName,
    required String contentType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'fotoProfil': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      });

      final response = await _apiClient.dio.put(
        ApiUrl.ortuDetail(ortuId),
        data: formData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        return Ortu.fromJson(responseData['data']);
      } else {
        throw UnexpectedException(message: 'Gagal mengunggah foto profil');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
