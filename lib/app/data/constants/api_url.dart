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
  static String get ustadz => '$baseUrl/ustadz';
  static String ustadzDetail(String ustadzId) => '$baseUrl/ustadz/$ustadzId';

  // ORTU
  static String get ortu => '$baseUrl/ortu';
  static String ortuDetail(String ortuId) => '$baseUrl/ortu/$ortuId';

  // SANTRI
  static String get santri => '$baseUrl/santri';

  static String santriDetail(String santriId) => '$baseUrl/santri/$santriId';

  static String get santriRank => '$baseUrl/santri/peringkat';

  // ALQURAN
  static String get surahList => '$baseUrl/alquran/surah';

  static String get juzList => '$baseUrl/alquran/juz';

  static String surahDetail(String surahId) =>
      '$baseUrl/alquran/surah/$surahId';

  static String juzDetail(String juzId) => '$baseUrl/alquran/juz/$juzId';

  // HAFALAN
  static String get saveSetoran => '$baseUrl/hafalan';

  static String get saveSetoranByAyat => '$baseUrl/hafalan/ayat';

  static String get saveSetoranByHalaman => '$baseUrl/hafalan/halaman';

  static String progresHafalanSurah(String santriId) =>
      '$baseUrl/hafalan/$santriId?mode=surah';

  static String progresHafalanJuz(String santriId) =>
      '$baseUrl/hafalan/$santriId?mode=juz';

  static String detailHafalanPerSurahTambah(String santriId, String surahId) =>
      '$baseUrl/hafalan/$santriId/surah/$surahId?mode=tambah';

  static String detailHafalanPerSurahMurajaah(
    String santriId,
    String surahId,
  ) => '$baseUrl/hafalan/$santriId/surah/$surahId?mode=murajaah';

  static String detailHafalanPerSurahTahsin(String santriId, String surahId) =>
      '$baseUrl/hafalan/$santriId/surah/$surahId?mode=tahsin';

  static String detailHafalanPerJuzTambah(String santriId, String juzId) =>
      '$baseUrl/hafalan/$santriId/juz/$juzId?mode=tambah';

  static String detailHafalanPerJuzMurajaah(String santriId, String juzId) =>
      '$baseUrl/hafalan/$santriId/juz/$juzId?mode=murajaah';

  static String detailHafalanPerJuzTahsin(String santriId, String juzId) =>
      '$baseUrl/hafalan/$santriId/juz/$juzId?mode=tahsin';

  // RIWAYAT HAFALAN
  static String get deleteRiwayatHafalan => '$baseUrl/hafalan/riwayat/';

  static String riwayatHafalan(String santriId) =>
      '$baseUrl/hafalan/riwayat/$santriId';

  static String detailRiwayatHafalan(String santriId, String surahId) =>
      '$baseUrl/hafalan/riwayat/detail/$santriId/surah/$surahId';

  static String detailRiwayatHafalanJuz(String santriId, String juzId) =>
      '$baseUrl/hafalan/riwayat/detail/$santriId/juz/$juzId';

  // SUMMARY HAFALAN
  static String get summaryHafalan => '$baseUrl/hafalan/all-santri/latest';

  // CHART
  static String get chart => '$baseUrl/chart';

  // ADMIN
  // DELETE USER
  static String deleteSantri(String santriId) => '$baseUrl/santri/$santriId';
  static String deleteOrtu(String ortuId) => '$baseUrl/ortu/$ortuId';
  static String deleteUstadz(String ustadzId) => '$baseUrl/ustadz/$ustadzId';
}
