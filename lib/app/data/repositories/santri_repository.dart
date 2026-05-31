import 'package:dio/dio.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';

import '../models/santri.dart';
import '../models/chart.dart' as c;

class SantriRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Santri> getSantri(String santriId) async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.santriDetail(santriId));

      if (response.statusCode == 200) {
        return Santri.fromJson(response.data['data']);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data santri');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> updateProfileData(String? nama, String santriId) async {
    try {
      await _apiClient.dio.put(
        ApiUrl.santriDetail(santriId),
        data: {'nama': nama},
      );
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<c.Chart> getChart(String range, String santriId, String mode) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.chart,
        queryParameters: {'range': range, 'santriId': santriId, 'mode': mode},
      );

      if (response.statusCode == 200) {
        return c.Chart.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data chart');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
