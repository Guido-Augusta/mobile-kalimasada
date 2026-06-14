import 'package:dio/dio.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_ayat.dart' as model_ayat;
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_halaman.dart' as model_halaman;
import 'package:mobile_kalimasada/app/data/models/detail_riwayat_ayat.dart';
import 'package:mobile_kalimasada/app/data/models/detail_riwayat_halaman.dart';

import '../exceptions/app_exception.dart';

class RiwayatRepository {
  final ApiClient _apiClient = ApiClient();

  Future<model_ayat.RiwayatHafalanAyat> getRiwayatAyat({
    required int santriId,
    required int page,
    required int limit,
    required String status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'status': status,
        'mode': 'ayat',
      };

      final response = await _apiClient.dio.get(
        ApiUrl.riwayatHafalan(santriId.toString()),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return model_ayat.RiwayatHafalanAyat.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data riwayat hafalan ayat');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<model_halaman.RiwayatHafalanHalaman> getRiwayatHalaman({
    required int santriId,
    required int page,
    required int limit,
    required String status,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
        'status': status,
        'mode': 'halaman',
      };

      final response = await _apiClient.dio.get(
        ApiUrl.riwayatHafalan(santriId.toString()),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return model_halaman.RiwayatHafalanHalaman.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data riwayat hafalan halaman');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> deleteRiwayatHafalan({
    required int santriId,
    required String tanggal,
    required String status,
    int? surahId,
    int? juzId,
    required String mode,
  }) async {
    try {
      final data = <String, dynamic>{
        'santriId': santriId,
        'tanggal': tanggal,
        'status': status,
      };

      if (mode == 'ayat' && surahId != null) {
        data['surahId'] = surahId;
      } else if (mode == 'halaman' && juzId != null) {
        data['juzId'] = juzId;
      }

      final response = await _apiClient.dio.delete(
        ApiUrl.deleteRiwayatHafalan,
        data: data,
      );

      if (response.statusCode != 200) {
        throw UnexpectedException(message: 'Gagal menghapus riwayat hafalan');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<DetailRiwayatAyat> getDetailRiwayatAyat({
    required String santriId,
    required String tanggal,
    required String status,
    required String surahId,
  }) async {
    try {
      final queryParams = {'tanggal': tanggal, 'status': status};

      final response = await _apiClient.dio.get(
        ApiUrl.detailRiwayatHafalan(santriId, surahId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return DetailRiwayatAyat.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat detail riwayat hafalan ayat');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<DetailRiwayatHalaman> getDetailRiwayatHalaman({
    required String santriId,
    required String tanggal,
    required String status,
    required String juzId,
  }) async {
    try {
      final queryParams = {'tanggal': tanggal, 'status': status};

      final response = await _apiClient.dio.get(
        ApiUrl.detailRiwayatHafalanJuz(santriId, juzId),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        return DetailRiwayatHalaman.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat detail riwayat hafalan halaman');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
