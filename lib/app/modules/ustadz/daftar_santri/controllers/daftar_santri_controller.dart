import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:mobile_kalimasada/app/data/models/surah.dart';
import 'package:mobile_kalimasada/app/data/models/ayat_hafalan.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaftarSantriController extends GetxController {
  final isLoading = false.obs;
  var santriList = <DaftarSantri>[].obs;
  var searchQuery = ''.obs;

  final int _perPage = 10;
  var currentPage = 1;
  var hasMore = true;
  var isLoadingMore = false;

  var surahList = <Surah>[].obs;
  var selectedSurah = Rxn<Surah>();
  var isLoadingSurah = false.obs;

  var isLoadingAyat = false.obs;
  var ayatList = <AyatHafalan>[].obs;
  var selectedAyatMulai = Rxn<AyatHafalan>();
  var selectedAyatAkhir = Rxn<AyatHafalan>();

  var statusSetoran = ''.obs;

  var catatanController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchSurahs();
  }

  void _resetPagination() {
    currentPage = 1;
    hasMore = true;
    santriList.clear();
  }

  void loadMoreData() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    currentPage++;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.get(
          Uri.parse(
            'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&search=${searchQuery.value}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-platform': 'mobile',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newItems = List<DaftarSantri>.from(
            data['data'].map((x) => DaftarSantri.fromJson(x)),
          );

          if (newItems.length < _perPage) {
            hasMore = false;
          }

          santriList.addAll(newItems);
        } else {
          currentPage--; // Revert page on error
          Get.snackbar('Error', 'Gagal memuat data tambahan');
        }
      }
    } catch (e) {
      currentPage--; // Revert page on error
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoadingMore = false;
    }
  }

  void fetchData() async {
    _resetPagination();
    isLoading.value = true;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.get(
          Uri.parse(
            'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&search=${searchQuery.value}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-platform': 'mobile',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final items = List<DaftarSantri>.from(
            data['data'].map((x) => DaftarSantri.fromJson(x)),
          );

          if (items.length < _perPage) {
            hasMore = false;
          }

          santriList.value = items;
        } else {
          Get.snackbar('Error', 'Gagal mendapatkan data');
        }
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSurahs() async {
    try {
      isLoadingSurah.value = true;
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/alquran/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> surahsData = data['data'];
        surahList.value = surahsData
            .map((json) => Surah.fromJson(json))
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load surahs');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while loading surahs');
    } finally {
      isLoadingSurah.value = false;
    }
  }

  Future<void> fetchAyatHafalanForSurah(String santriId, String surahId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      isLoadingAyat.value = true;
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/$santriId/surah/$surahId?mode=tambah',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ayatData = data['ayat'];
        ayatList.value = ayatData
            .map((json) => AyatHafalan.fromJson(json))
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load ayat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
    } finally {
      isLoadingAyat.value = false;
    }
  }

  Future<void> fetchAyatMurajaahForSurah(
    String santriId,
    String surahId,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      isLoadingAyat.value = true;
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/$santriId/surah/$surahId?mode=murajaah',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ayatData = data['ayat'];
        ayatList.value = ayatData
            .map((json) => AyatHafalan.fromJson(json))
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load ayat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
    } finally {
      isLoadingAyat.value = false;
    }
  }

  void onSurahSelected(Surah? newSurah, String santriId, String statusSetoran) {
    // Reset selections when changing surah
    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;

    if (newSurah != null) {
      selectedSurah.value = newSurah;
      if (statusSetoran == 'TambahHafalan') {
        fetchAyatHafalanForSurah(santriId, newSurah.id.toString());
      } else if (statusSetoran == 'Murajaah') {
        fetchAyatMurajaahForSurah(santriId, newSurah.id.toString());
      } else {
        Get.snackbar('Error', 'Invalid status setoran');
      }
    }
  }

  void saveHafalan(String santriId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ustadzId = prefs.getString('roleId');
    var ayatIds = [];
    if (selectedAyatMulai.value != null && selectedAyatAkhir.value != null) {
      ayatIds = List.generate(
        selectedAyatAkhir.value!.id! - selectedAyatMulai.value!.id! + 1,
        (index) => selectedAyatMulai.value!.id! + index,
      );
    }
    print(santriId);
    print(ustadzId);
    print(ayatIds);
    print(statusSetoran.value);
    print(catatanController.text);
    try {
      isLoadingAyat.value = true;
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/hafalan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'ustadzId': ustadzId,
          'ayatIds': ayatIds,
          'status': statusSetoran.value,
          'catatan': catatanController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        Get.snackbar('Success', 'Hafalan berhasil ditambahkan');
      } else {
        Get.snackbar('Error', 'Gagal menambahkan hafalan');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan hafalan');
    } finally {
      isLoadingAyat.value = false;
    }

    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;
    selectedSurah.value = null;
    statusSetoran.value = '';
    catatanController.clear();
  }

  void saveMurajaah(String santriId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ustadzId = prefs.getString('roleId');
    var ayatIds = [];
    if (selectedAyatMulai.value != null && selectedAyatAkhir.value != null) {
      ayatIds = List.generate(
        selectedAyatAkhir.value!.id! - selectedAyatMulai.value!.id! + 1,
        (index) => selectedAyatMulai.value!.id! + index,
      );
    }
    print(santriId);
    print(ustadzId);
    print(ayatIds);
    print(statusSetoran.value);
    print(catatanController.text);
    try {
      isLoadingAyat.value = true;
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/hafalan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'ustadzId': ustadzId,
          'ayatIds': ayatIds,
          'status': statusSetoran.value,
          'catatan': catatanController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        Get.snackbar('Success', 'Hafalan berhasil ditambahkan');
      } else {
        Get.snackbar('Error', 'Gagal menambahkan hafalan');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan hafalan');
    } finally {
      isLoadingAyat.value = false;
    }

    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;
    selectedSurah.value = null;
    statusSetoran.value = '';
    catatanController.clear();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  String getTahapanSantri(String tahapan) {
    if (tahapan == 'Tahap1_Juz30') {
      return 'Tahap 1 - Juz 30';
    } else if (tahapan == 'Tahap2_SuratPilihan') {
      return 'Tahap 2 - Surat Pilihan';
    } else if (tahapan == 'Tahap3_Juz1_29') {
      return 'Tahap 3 - Juz 1-29';
    } else {
      return 'Belum ada tahapan';
    }
  }
}
