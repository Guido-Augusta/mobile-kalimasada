import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_ustadz.dart' as daftar;
import 'package:mobile_kalimasada/app/data/models/ustadz.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';

class UstadzRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch paginated list of ustadz
  Future<daftar.DaftarUstadz> fetchUstadzList({
    required int page,
    required int limit,
    String search = '',
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.ustadz,
        queryParameters: {'page': page, 'limit': limit, 'search': search},
      );

      if (response.statusCode == 200) {
        return daftar.DaftarUstadz.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat daftar ustadz');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Get single ustadz detail
  Future<Ustadz> getUstadz(String ustadzId) async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.ustadzDetail(ustadzId));

      if (response.statusCode == 200) {
        return Ustadz.fromJson(response.data['data']);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data ustadz');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Update ustadz profile
  Future<Ustadz> updateProfile(
    String ustadzId,
    String nama,
    String noHp,
    String alamat,
    String jenisKelamin,
    String? waliKelasTahap,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        ApiUrl.ustadzDetail(ustadzId),
        data: {
          'nama': nama,
          'nomorHp': noHp,
          'alamat': alamat,
          'jenisKelamin': jenisKelamin,
          'waliKelasTahap': ?waliKelasTahap,
        },
      );

      if (response.statusCode == 200) {
        return Ustadz.fromJson(response.data['data']);
      } else {
        throw UnexpectedException(message: 'Gagal memperbarui data ustadz');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Update ustadz email and/or password
  Future<Ustadz> updateEmailPassword(
    String ustadzId,
    String? email,
    String? password,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        ApiUrl.ustadzDetail(ustadzId),
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        return Ustadz.fromJson(response.data['data']);
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

  /// Upload profile photo
  Future<Ustadz> uploadFotoProfil({
    required String ustadzId,
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
        ApiUrl.ustadzDetail(ustadzId),
        data: formData,
      );

      if (response.statusCode == 200) {
        return Ustadz.fromJson(response.data['data']);
      } else {
        throw UnexpectedException(message: 'Gagal mengunggah foto profil');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Delete ustadz account
  Future<void> deleteUstadz(String ustadzId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiUrl.deleteUstadz(ustadzId),
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Gagal menghapus ustadz/ah');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Add new ustadz (multipart for optional photo)
  Future<Map<String, dynamic>> addUstadz({
    required String email,
    required String password,
    required String nama,
    required String noHp,
    required String jenisKelamin,
    required String alamat,
    required String waliKelasTahap,
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
        'alamat': alamat,
        'waliKelasTahap': waliKelasTahap,
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
      final response = await _apiClient.dio.post(ApiUrl.ustadz, data: formData);

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw UnexpectedException(message: 'Gagal menambahkan ustadz');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
