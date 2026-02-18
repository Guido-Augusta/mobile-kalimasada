import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUrl {
  static String get baseUrl {
    String? url = dotenv.env['BASE_URL'];

    // Jika url kosong atau null, hentikan aplikasi dan beri pesan error jelas
    if (url == null || url.isEmpty) {
      throw Exception(
        'BASE_URL tidak ditemukan. Pastikan file .env sudah dibuat!',
      );
    }

    return url;
  }

  // ENDPOINTS
  // AUTH
  static String get login => '$baseUrl/auth/login';

  static String logout(String userId) => '$baseUrl/auth/logout/$userId';

  // CHANGE PASSWORD
  static String get verifyOldPassword => '$baseUrl/auth/verify-old-password';

  static String get changePassword => '$baseUrl/auth/change-password';

  // FORGOT PASSWORD
  static String get forgotPassword => '$baseUrl/auth/forgot-password';

  static String get verifyToken => '$baseUrl/auth/verify-token';

  static String get resetPassword => '$baseUrl/auth/reset-password';

  // USTADZ
  static String ustadz(String ustadzId) => '$baseUrl/ustadz/$ustadzId';

  // ORTU
  static String ortu(String ortuId) => '$baseUrl/ortu/$ortuId';

  // SANTRI
  static String get santriList => '$baseUrl/santri';

  static String santriDetail(String santriId) => '$baseUrl/santri/$santriId';

  static String get santriRank => '$baseUrl/santri/peringkat';

  // ALQURAN
  static String get surahList => '$baseUrl/alquran';

  static String surahDetail(String surahId) =>
      '$baseUrl/alquran/surah/$surahId';

  // HAFALAN
  static String get saveSetoran => '$baseUrl/hafalan';

  static String progresHafalan(String santriId) =>
      '$baseUrl/hafalan/$santriId/surah';

  static String detailHafalanPerSurahTambah(String santriId, String surahId) =>
      '$baseUrl/hafalan/$santriId/surah/$surahId?mode=tambah';

  static String detailHafalanPerSurahMurajaah(
    String santriId,
    String surahId,
  ) => '$baseUrl/hafalan/$santriId/surah/$surahId?mode=murajaah';

  // RIWAYAT HAFALAN
  static String get deleteRiwayatHafalan => '$baseUrl/hafalan/riwayat/';

  static String riwayatHafalan(String santriId) =>
      '$baseUrl/hafalan/riwayat/$santriId';

  static String detailRiwayatHafalan(String santriId, String surahId) =>
      '$baseUrl/hafalan/riwayat/detail/$santriId/surah/$surahId';

  // SUMMARY HAFALAN
  static String get summaryHafalan => '$baseUrl/hafalan/all-santri/latest';

  // CHART
  static String get chart => '$baseUrl/chart';

  // ADMIN
  // DELETE SANTRI
  static String deleteSantri(String santriId) => '$baseUrl/santri/$santriId';
}
