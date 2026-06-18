import 'package:dio/dio.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';

import '../constants/api_url.dart';
import '../exceptions/app_exception.dart';
import '../models/daftar_surah.dart';
import '../models/daftar_juz.dart' as juz_model;
import '../models/detail_surah.dart';
import '../models/detail_juz.dart';

class QuranRepository {
  final ApiClient _apiClient = ApiClient();

  /// Fetch daftar seluruh surah
  Future<DaftarSurah> fetchSurahList() async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.surahList);
      if (response.statusCode == 200) {
        return DaftarSurah.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat daftar surah');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Fetch daftar seluruh juz
  Future<juz_model.DaftarJuz> fetchJuzList() async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.juzList);
      if (response.statusCode == 200) {
        return juz_model.DaftarJuz.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat daftar juz');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Fetch detail surah beserta ayat-ayatnya
  Future<DetailSurah> fetchSurahDetail(String surahId) async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.surahDetail(surahId));
      if (response.statusCode == 200) {
        return DetailSurah.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data surah');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  /// Fetch detail juz beserta ayat-ayatnya
  Future<DetailJuz> fetchJuzDetail(String juzId) async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.juzDetail(juzId));
      if (response.statusCode == 200) {
        return DetailJuz.fromJson(response.data);
      } else {
        throw UnexpectedException(message: 'Gagal memuat data juz');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
