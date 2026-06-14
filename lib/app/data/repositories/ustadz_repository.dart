import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/ustadz.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';

class UstadzRepository {
  final ApiClient _apiClient = ApiClient();

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

  Future<Ustadz> updateProfile(
    String ustadzId,
    String nama,
    String noHp,
    String alamat,
    String jenisKelamin,
  ) async {
    try {
      final response = await _apiClient.dio.put(
        ApiUrl.ustadzDetail(ustadzId),
        data: {
          'nama': nama,
          'nomorHp': noHp,
          'alamat': alamat,
          'jenisKelamin': jenisKelamin,
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
}
