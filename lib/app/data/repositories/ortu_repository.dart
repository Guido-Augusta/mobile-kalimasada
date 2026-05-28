// lib/app/data/repositories/ortu_repository.dart
import 'package:dio/dio.dart';
import '../constants/api_url.dart';
import '../exceptions/app_exception.dart';
import '../models/daftar_santri.dart';
import '../models/ortu.dart';
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
}
