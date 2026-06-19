// lib/app/data/repositories/ortu_repository.dart
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/api_url.dart';
import '../exceptions/app_exception.dart';
import '../models/daftar_ortu.dart' as daftar;
import '../models/daftar_santri.dart';
import '../models/ortu.dart';
import '../models/santri.dart' as s;
import '../providers/api_client.dart';

class OrtuRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch paginated list of ortu
  Future<daftar.DaftarOrtu> fetchOrtuList({
    required int page,
    required int limit,
    String search = '',
    String? tipe,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        'search': search,
      };
      if (tipe != null && tipe.trim().isNotEmpty) {
        queryParams['tipe'] = tipe;
      }

      final response = await _apiClient.dio.get(
        ApiUrl.ortu,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return daftar.DaftarOrtu.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat daftar orang tua');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Mengambil detail orang tua berdasarkan ortuId
  Future<Ortu> getOrtuDetail(String ortuId) async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.ortuDetail(ortuId));

      if (response.statusCode == 200) {
        final responseData = response.data;
        return Ortu.fromJson(responseData['data']);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data orang tua');
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

  /// Memperbarui data profil orang tua (nama, noHp, alamat, jenisKelamin, tipe)
  Future<Ortu> updateProfile({
    required String ortuId,
    required String nama,
    required String noHp,
    required String alamat,
    required String jenisKelamin,
    required String tipe,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiUrl.ortuDetail(ortuId),
        data: {
          'nama': nama,
          'nomorHp': noHp,
          'alamat': alamat,
          'jenisKelamin': jenisKelamin,
          'tipe': tipe,
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

  /// Update email dan/atau password orang tua
  Future<Ortu> updateEmailPassword({
    required String ortuId,
    String? email,
    String? password,
  }) async {
    try {
      final response = await _apiClient.dio.put(
        ApiUrl.ortuDetail(ortuId),
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return Ortu.fromJson(response.data['data']);
      } else {
        throw UnexpectedException(
          message: 'Gagal memperbarui email dan password',
        );
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

  /// Delete ortu account
  Future<void> deleteOrtu(String ortuId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiUrl.deleteOrtu(ortuId),
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Gagal menghapus orang tua');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Add new ortu (multipart for optional photo)
  Future<Map<String, dynamic>> addOrtu({
    required String email,
    required String password,
    required String nama,
    required String noHp,
    required String jenisKelamin,
    required String tipe,
    required String alamat,
    List<int>? fotoBytes,
    String? fotoFileName,
    String? fotoContentType,
  }) async {
    try {
      final Map<String, dynamic> formMap = {
        'email': email,
        'password': password,
        'nama': nama,
        'nomorHp': noHp,
        'jenisKelamin': jenisKelamin,
        'tipe': tipe,
        'alamat': alamat,
      };

      if (fotoBytes != null &&
          fotoFileName != null &&
          fotoContentType != null) {
        formMap['fotoProfil'] = MultipartFile.fromBytes(
          fotoBytes,
          filename: fotoFileName,
          contentType: MediaType.parse(fotoContentType),
        );
      }

      final formData = FormData.fromMap(formMap);
      final response = await _apiClient.dio.post(ApiUrl.ortu, data: formData);

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw UnexpectedException(message: 'Gagal menambahkan orang tua');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
