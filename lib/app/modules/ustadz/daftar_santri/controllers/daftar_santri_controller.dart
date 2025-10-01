import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:mobile_kalimasada/app/data/models/surah.dart' as Surah;
import 'package:mobile_kalimasada/app/data/models/ayat_hafalan.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan.dart'
    as DetailHafalan;
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaftarSantriController extends GetxController {
  final isLoading = false.obs;
  final isSaveLoading = false.obs;
  var santriList = <Datum>[].obs;
  var searchQuery = ''.obs;
  var tahapHafalan = 'level1'.obs;

  final int _perPage = 10;
  var currentPage = 1;
  var hasMore = true;
  var isLoadingMore = false;

  var isLoadingSurah = false.obs;
  var surahList = <Surah.Surah>[].obs;
  var selectedSurahHafalan = Rxn<SearchFieldListItem<Surah.Surah>>();
  var selectedSurahMurajaah = Rxn<SearchFieldListItem<Surah.Surah>>();
  var detailHafalan = Rx<DetailHafalan.DetailHafalan?>(null);

  var isLoadingAyat = false.obs;
  var inputJumlahAyatController = TextEditingController();
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
            'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&tahapHafalan=${tahapHafalan.value}&search=${searchQuery.value}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-platform': 'mobile',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newItems = List<Datum>.from(
            data['data'].map((x) => Datum.fromJson(x)),
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
            'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&tahapHafalan=${tahapHafalan.value}&search=${searchQuery.value}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-platform': 'mobile',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final items = List<Datum>.from(
            data['data'].map((x) => Datum.fromJson(x)),
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
            .map((json) => Surah.Surah.fromJson(json))
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

  void onSurahSelected(
    Surah.Surah? newSurah,
    String santriId,
    String statusSetoran,
  ) {
    // Reset selections when changing surah
    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;

    if (newSurah != null) {
      if (statusSetoran == 'TambahHafalan') {
        getDetailTambahHafalan(santriId, newSurah.id.toString());
      } else if (statusSetoran == 'Murajaah') {
        // selectedSurahMurajaah.value = newSurah;
        fetchAyatMurajaahForSurah(santriId, newSurah.id.toString());
      } else {
        Get.snackbar('Error', 'Invalid status setoran');
      }
    }
  }

  void getDetailTambahHafalan(String santriId, String surahId) async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
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
        detailHafalan.value = DetailHafalan.DetailHafalan.fromJson(data);
      } else {
        Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
    } finally {
      isLoading.value = false;
    }
  }

  void saveHafalan(String santriId) async {
    isSaveLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ustadzId = prefs.getString('roleId');
    var ayatIds = [];

    // Logika otomatis mengisi ayatIds
    if (detailHafalan.value != null && detailHafalan.value!.ayat.isNotEmpty) {
      // 1. Cari ayat terakhir yang sudah dihafalkan (checked = true)
      int lastHafalanAyatNumber = 0;
      for (var ayat in detailHafalan.value!.ayat) {
        if (ayat.checked == true) {
          lastHafalanAyatNumber = ayat.nomorAyat ?? 0;
        }
      }

      // 2. Dapatkan daftar ayat yang belum dihafalkan (checked = false)
      List<DetailHafalan.Ayat> uncheckedAyats = detailHafalan.value!.ayat
          .where((ayat) => ayat.checked == false)
          .toList();

      // 3. Urutkan berdasarkan nomor ayat
      uncheckedAyats.sort(
        (a, b) => (a.nomorAyat ?? 0).compareTo(b.nomorAyat ?? 0),
      );

      // 4. Ambil ayat-ayat berikutnya sesuai jumlah yang diinput
      int jumlahAyatDitambahkan = int.parse(inputJumlahAyatController.text);
      if (jumlahAyatDitambahkan <= 0) {
        Get.snackbar('Error', 'Jumlah ayat harus lebih dari 0');
        isSaveLoading.value = false;
        return;
      }
      if (jumlahAyatDitambahkan > 0) {
        // Cari ayat pertama yang belum dihafalkan setelah ayat terakhir yang dihafalkan
        List<DetailHafalan.Ayat> ayatsToBeAdded = [];
        bool foundStartingPoint = false;

        for (var ayat in uncheckedAyats) {
          if (!foundStartingPoint) {
            // Cari ayat pertama yang lebih besar dari ayat terakhir yang dihafalkan
            if ((ayat.nomorAyat ?? 0) > lastHafalanAyatNumber) {
              foundStartingPoint = true;
            }
          }

          if (foundStartingPoint) {
            ayatsToBeAdded.add(ayat);
            if (ayatsToBeAdded.length >= jumlahAyatDitambahkan) {
              break;
            }
          }
        }

        // 5. Ambil ID dari ayat-ayat yang akan ditambahkan
        ayatIds = ayatsToBeAdded.map((ayat) => ayat.id).toList();
      }
    }

    print('santriId: $santriId');
    print('ustadzId: $ustadzId');
    print('ayatIds: $ayatIds');
    print('statusSetoran: ${statusSetoran.value}');
    print('catatan: ${catatanController.text}');
    try {
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
        Get.back();
        Get.snackbar('Success', 'Hafalan berhasil ditambahkan');
      } else {
        Get.snackbar('Error', 'Gagal menambahkan hafalan');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan hafalan');
    } finally {
      isSaveLoading.value = false;
    }

    ayatIds = [];
    inputJumlahAyatController.text = '';
    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;
    selectedSurahHafalan.value = null;
    statusSetoran.value = '';
    catatanController.clear();
    isSaveLoading.value = false;
  }

  void saveMurajaah(String santriId) async {
    isSaveLoading.value = true;
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
        Get.back();
        Get.snackbar('Success', 'Hafalan berhasil ditambahkan');
      } else {
        Get.snackbar('Error', 'Gagal menambahkan hafalan');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Terjadi kesalahan saat menambahkan hafalan');
    } finally {
      isSaveLoading.value = false;
    }

    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;
    selectedSurahMurajaah.value = null;
    statusSetoran.value = '';
    catatanController.clear();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  String getTahapanSantri(String tahapan) {
    if (tahapan == 'Level1') {
      return 'Level 1';
    } else if (tahapan == 'Level2') {
      return 'Level 2';
    } else if (tahapan == 'Level3') {
      return 'Level 3';
    } else {
      return 'Belum ada tahapan';
    }
  }

  String getTahapanFilter(String tahapan) {
    if (tahapan == 'level1') {
      return 'level 1';
    } else if (tahapan == 'level2') {
      return 'level 2';
    } else if (tahapan == 'level3') {
      return 'level 3';
    } else {
      return 'Tidak ada tahapan';
    }
  }
}
