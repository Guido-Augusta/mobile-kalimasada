import 'package:dio/dio.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';

import '../constants/api_url.dart';
import '../exceptions/app_exception.dart';
import '../models/detail_surah.dart';

class QuranRepository {
  final ApiClient _apiClient = ApiClient();

  Future<DetailSurah> fetchSurahDetail(String surahId) async {
    try {
      final response = await _apiClient.dio.get(ApiUrl.surahDetail(surahId));
      if (response.statusCode == 200) {
        final data = DetailSurah.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat data surah');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
