import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart' as ds;
import 'package:mobile_kalimasada/app/data/models/progres_hafalan.dart' as ph;
import 'package:mobile_kalimasada/app/data/models/surah.dart' as s;
import 'package:mobile_kalimasada/app/data/models/ayat_hafalan.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan.dart' as dh;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaftarSantriController extends GetxController {
  final isLoading = false.obs;
  final isSaveLoading = false.obs;

  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  var tahapHafalan = 'level1'.obs;

  var santriList = <ds.Datum>[].obs;
  var progresHafalan = <ph.Datum>[].obs;
  var progressPercentage = 0.0.obs;
  var currentAyat = 0.obs;
  var totalAyat = 0.obs;

  final int _perPage = 20;
  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  var isLoadingSurah = false.obs;
  var surahList = <s.Surah>[].obs;
  var selectedSurahHafalan = Rxn<SearchFieldListItem<s.Surah>>();
  var selectedSurahMurajaah = Rxn<SearchFieldListItem<s.Surah>>();
  var detailHafalan = Rx<dh.DetailHafalan?>(null);

  var isLoadingAyat = false.obs;
  var inputJumlahAyatController = TextEditingController();
  var ayatList = <AyatHafalan>[].obs;
  var selectedAyatMulai = Rxn<AyatHafalan>();
  var selectedAyatAkhir = Rxn<AyatHafalan>();

  var statusSetoran = ''.obs;

  var catatanController = TextEditingController();

  final formKeyHafalan = GlobalKey<FormState>();
  final formKeyMurajaah = GlobalKey<FormState>();

  final scrollController = ScrollController();

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();

    fetchData();
    _setupScrollController();

    debounce(searchQuery, (callback) {
      fetchData();
    }, time: const Duration(milliseconds: 700));
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _resetPagination() {
    currentPage = 1;
    hasMore.value = true;
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreData();
        }
      }
    });
  }

  void fetchData() async {
    try {
      isLoading.value = true;
      _resetPagination();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'tahapHafalan': tahapHafalan.value,
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.santriList,
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        santriList.clear();
        final data = jsonDecode(response.body);
        final items = List<ds.Datum>.from(
          data['data'].map((x) => ds.Datum.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        santriList.value = items;
        fetchSurahs();
      } else {
        ToastUtils.showErrorToast('Gagal memuat data');
      }
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void changeTahapHafalan(String tahapHafalan) {
    if (tahapHafalan.toLowerCase() == this.tahapHafalan.value.toLowerCase()) {
      return;
    }
    this.tahapHafalan.value = tahapHafalan;
    santriList.clear();
    fetchData();
  }

  void loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'tahapHafalan': tahapHafalan.value,
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.santriList,
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newItems = List<ds.Datum>.from(
          data['data'].map((x) => ds.Datum.fromJson(x)),
        );

        if (newItems.length < _perPage) {
          hasMore.value = false;
        }

        santriList.addAll(newItems);
      } else {
        currentPage--; // Revert page on error
        ToastUtils.showErrorToast('Gagal memuat data tambahan');
      }
    } catch (e) {
      currentPage--; // Revert page on error
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void fetchSurahs() async {
    try {
      isLoadingSurah.value = true;
      final response = await http.get(
        Uri.parse(ApiUrl.surahList),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> surahsData = data['data'];
        surahList.value = surahsData
            .map((json) => s.Surah.fromJson(json))
            .toList();
      } else {
        ToastUtils.showErrorToast('Gagal memuat data surah');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isLoadingSurah.value = false;
    }
  }

  Future<void> fetchAyatMurajaahForSurah(
    String santriId,
    String surahId,
  ) async {
    try {
      isLoadingAyat.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerSurahMurajaah(santriId, surahId)),
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
        ToastUtils.showErrorToast('Gagal memuat data ayat');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isLoadingAyat.value = false;
    }
  }

  void onSurahSelected(
    s.Surah? newSurah,
    String santriId,
    String statusSetoran,
  ) {
    // Reset selections when changing surah
    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;

    if (newSurah != null) {
      getProgresAyat(newSurah.id!);
      if (statusSetoran == 'TambahHafalan') {
        getDetailTambahHafalan(santriId, newSurah.id.toString());
      } else if (statusSetoran == 'Murajaah') {
        fetchAyatMurajaahForSurah(santriId, newSurah.id.toString());
      } else {
        ToastUtils.showErrorToast('Invalid status setoran');
      }
    }
  }

  void getProgresAyat(int surahId) {
    // Parse progress string to get current and total ayat
    final progressParts =
        progresHafalan
            .where((element) => element.id == surahId)
            .first
            .progress
            ?.split('/') ??
        ['0', '0'];
    currentAyat.value = int.tryParse(progressParts[0]) ?? 0;
    totalAyat.value =
        progresHafalan
            .where((element) => element.id == surahId)
            .first
            .totalAyat ??
        int.tryParse(progressParts[1]) ??
        0;
    progressPercentage.value = totalAyat.value > 0
        ? (currentAyat.value / totalAyat.value)
        : 0.0;
  }

  Future<void> getProgresHafalan(String santriId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.progresHafalan(santriId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        progresHafalan.value = List<ph.Datum>.from(
          data['data'].map((x) => ph.Datum.fromJson(x)),
        );
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat');
      }
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    }
  }

  void getDetailTambahHafalan(String santriId, String surahId) async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerSurahTambah(santriId, surahId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        detailHafalan.value = dh.DetailHafalan.fromJson(data);
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
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
      List<dh.Ayat> uncheckedAyats = detailHafalan.value!.ayat
          .where((ayat) => ayat.checked == false)
          .toList();

      // 3. Urutkan berdasarkan nomor ayat
      uncheckedAyats.sort(
        (a, b) => (a.nomorAyat ?? 0).compareTo(b.nomorAyat ?? 0),
      );

      // 4. Ambil ayat-ayat berikutnya sesuai jumlah yang diinput
      int jumlahAyatDitambahkan = int.parse(inputJumlahAyatController.text);
      if (jumlahAyatDitambahkan <= 0) {
        ToastUtils.showErrorToast('Jumlah ayat harus lebih dari 0');
        isSaveLoading.value = false;
        return;
      }
      if (jumlahAyatDitambahkan > 0) {
        // Cari ayat pertama yang belum dihafalkan setelah ayat terakhir yang dihafalkan
        List<dh.Ayat> ayatsToBeAdded = [];
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
        Uri.parse(ApiUrl.saveSetoran),
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
        Future.delayed(const Duration(milliseconds: 500), () {
          ayatIds = [];
          inputJumlahAyatController.text = '';
          selectedSurahHafalan.value = null;
          currentAyat.value = 0;
          totalAyat.value = 0;
          progressPercentage.value = 0;
          statusSetoran.value = '';
          catatanController.clear();
        });
        ToastUtils.showSuccessToast('Hafalan berhasil ditambahkan');
      } else {
        ToastUtils.showErrorToast('Gagal menambahkan hafalan');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isSaveLoading.value = false;
    }
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
        Uri.parse(ApiUrl.saveSetoran),
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
        Future.delayed(const Duration(milliseconds: 500), () {
          selectedAyatMulai.value = null;
          selectedAyatAkhir.value = null;
          selectedSurahMurajaah.value = null;
          statusSetoran.value = '';
          catatanController.clear();
          currentAyat.value = 0;
          totalAyat.value = 0;
          progressPercentage.value = 0;
        });
        ToastUtils.showSuccessToast('Murajaah berhasil ditambahkan');
      } else {
        ToastUtils.showErrorToast('Gagal menambah murajaah');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isSaveLoading.value = false;
    }
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
