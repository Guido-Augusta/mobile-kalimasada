import 'package:dio/dio.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';

import '../models/daftar_santri.dart';
import '../models/santri.dart';
import '../models/peringkat.dart' as p;
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

  Future<List<Datum>> getSantriList({
    required int currentPage,
    required int limit,
    required String tahapHafalan,
    required String search,
  }) async {
    try {
      final queryParams = {
        'page': currentPage.toString(),
        'limit': limit.toString(),
        'tahapHafalan': tahapHafalan,
        'search': search,
      };

      final response = await _apiClient.dio.get(
        ApiUrl.santri,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final santriList = List<Datum>.from(data.map((x) => Datum.fromJson(x)));
        return santriList;
      } else {
        throw UnexpectedException(message: 'Gagal memuat data santri');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> updateNamaSantri(String? nama, String santriId) async {
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

  Future<void> updateTahapHafalan(String tahapHafalan, String santriId) async {
    try {
      await _apiClient.dio.put(
        ApiUrl.santriDetail(santriId),
        data: {'tahapHafalan': tahapHafalan},
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

  Future<List<p.Datum>> getPeringkatList({
    required int currentPage,
    required int limit,
    required String search,
    required String tahapHafalan,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.santriRank,
        queryParameters: {
          'page': currentPage.toString(),
          'limit': limit.toString(),
          'search': search,
          'tahapHafalan': tahapHafalan,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final peringkatList = List<p.Datum>.from(
          data.map((x) => p.Datum.fromJson(x)),
        );
        return peringkatList;
      } else {
        throw UnexpectedException(message: 'Gagal memuat data peringkat');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> deleteSantri(String santriId) async {
    try {
      final response = await _apiClient.dio.delete(
        ApiUrl.deleteSantri(santriId),
      );
      if (response.statusCode == 200) {
        return;
      } else {
        throw UnexpectedException(message: 'Gagal menghapus data santri');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
