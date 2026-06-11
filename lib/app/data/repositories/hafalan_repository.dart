import 'package:dio/dio.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan_surah.dart';
import 'package:mobile_kalimasada/app/data/providers/api_client.dart';

import '../models/detail_hafalan_juz.dart';
import '../models/progres_hafalan_juz.dart' as j;
import '../models/progres_hafalan_surah.dart';
import '../models/summary_hafalan_juz.dart' as juz_model;
import '../models/summary_hafalan_surah.dart' as surah_model;

class HafalanRepository {
  final ApiClient _apiClient = ApiClient();

  // PROGRES HAFALAN SURAH

  Future<ProgresHafalanSurah> fetchProgresHafalanSurah({
    required String santriId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.progresHafalanSurah(santriId),
      );
      if (response.statusCode == 200) {
        final data = ProgresHafalanSurah.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat data progres hafalan');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  // PROGRES HAFALAN JUZ

  Future<List<j.Datum>> fetchProgresHafalanJuz({
    required String santriId,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.progresHafalanJuz(santriId),
      );
      if (response.statusCode == 200) {
        final data = j.ProgresHafalanJuz.fromJson(response.data);
        return data.data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat data progres hafalan');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  // DETAIL HAFALAN SURAH

  Future<DetailHafalanSurah> fetchDetailHafalanSurah(
    String santriId,
    String surahId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.detailHafalanPerSurahTambah(santriId, surahId),
      );
      if (response.statusCode == 200) {
        final data = DetailHafalanSurah.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat ayat hafalan');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<DetailHafalanSurah> fetchDetailMurajaahSurah(
    String santriId,
    String surahId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.detailHafalanPerSurahMurajaah(santriId, surahId),
      );
      if (response.statusCode == 200) {
        final data = DetailHafalanSurah.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat ayat murajaah');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<DetailHafalanSurah> fetchDetailTahsinSurah(
    String santriId,
    String surahId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.detailHafalanPerSurahTahsin(santriId, surahId),
      );
      if (response.statusCode == 200) {
        final data = DetailHafalanSurah.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat ayat tahsin');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> saveSetoranByAyat(
    int santriId,
    int surahId,
    List<int> ayatIds,
    String status,
    String? kualitas,
    String keterangan,
    String? catatan,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiUrl.saveSetoranByAyat,
        data: {
          'santriId': santriId,
          'surahId': surahId,
          'ayatIds': ayatIds,
          'status': status,
          'kualitas': kualitas ?? 'Baik', // Kurang, Cukup, Baik, SangatBaik,
          'keterangan': keterangan, // Lanjut, Mengulang
          'catatan': catatan ?? '',
        },
      );
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  // DETAIL HAFALAN JUZ

  Future<DetailHafalanJuz> fetchDetailHafalanJuz(
    String santriId,
    String juzId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.detailHafalanPerJuzTambah(santriId, juzId),
      );
      if (response.statusCode == 200) {
        final data = DetailHafalanJuz.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat ayat hafalan');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<DetailHafalanJuz> fetchDetailMurajaahJuz(
    String santriId,
    String juzId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.detailHafalanPerJuzMurajaah(santriId, juzId),
      );
      if (response.statusCode == 200) {
        final data = DetailHafalanJuz.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat ayat murajaah');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<DetailHafalanJuz> fetchDetailTahsinJuz(
    String santriId,
    String juzId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.detailHafalanPerJuzTahsin(santriId, juzId),
      );
      if (response.statusCode == 200) {
        final data = DetailHafalanJuz.fromJson(response.data);
        return data;
      } else {
        throw UnexpectedException(message: 'Gagal memuat ayat tahsin');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  Future<void> saveSetoranByHalaman(
    int santriId,
    int juzId,
    int halamanMulai,
    int halamanSelesai,
    String status,
    String? kualitas,
    String keterangan,
    String? catatan,
  ) async {
    try {
      await _apiClient.dio.post(
        ApiUrl.saveSetoranByHalaman,
        data: {
          'santriId': santriId,
          'juzId': juzId,
          'halamanAwal': halamanMulai,
          'halamanAkhir': halamanSelesai,
          'status': status,
          'kualitas': kualitas ?? 'Baik', // Kurang, Cukup, Baik, SangatBaik,
          'keterangan': keterangan, // Lanjut, Mengulang
          'catatan': catatan ?? '',
        },
      );
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  // SUMMARY HAFALAN SURAH
  Future<List<surah_model.Datum>> fetchSummaryHafalanSurah({
    required int page,
    required int limit,
    required String status,
    required String tahapHafalan,
    required String sortByAyat,
    required String name,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.summaryHafalan,
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': status,
          'tahapHafalan': tahapHafalan,
          'sortByAyat': sortByAyat,
          'name': name,
          'mode': 'surah',
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final items = List<surah_model.Datum>.from(
          data['data'].map((x) => surah_model.Datum.fromJson(x)),
        );
        return items;
      } else {
        throw UnexpectedException(message: 'Gagal memuat data ringkasan hafalan');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }

  // SUMMARY HAFALAN JUZ
  Future<List<juz_model.Datum>> fetchSummaryHafalanJuz({
    required int page,
    required int limit,
    required String status,
    required String tahapHafalan,
    required String sortByHalaman,
    required String name,
  }) async {
    try {
      final response = await _apiClient.dio.get(
        ApiUrl.summaryHafalan,
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': status,
          'tahapHafalan': tahapHafalan,
          'sortByHalaman': sortByHalaman,
          'name': name,
          'mode': 'juz',
        },
      );
      if (response.statusCode == 200) {
        final data = response.data;
        final items = List<juz_model.Datum>.from(
          data['data'].map((x) => juz_model.Datum.fromJson(x)),
        );
        return items;
      } else {
        throw UnexpectedException(message: 'Gagal memuat data ringkasan hafalan');
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw UnexpectedException(message: e.toString());
    }
  }
}
