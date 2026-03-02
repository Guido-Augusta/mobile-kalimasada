import 'package:flutter/foundation.dart';
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
  var userRole = ''.obs;
  bool get isAdmin => userRole.value == 'admin';

  final isLoading = false.obs;
  final isSaveLoading = false.obs;
  final isLoadingProgresHafalan = false.obs;
  final isLoadingDeleteAccount = false.obs;

  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  var tahapHafalan = 'level1'.obs;

  var santriList = <ds.Datum>[].obs;
  var progresHafalan = <ph.Datum>[].obs;
  var progressPercentage = 0.0.obs;
  var currentAyat = 0.obs;
  var totalAyat = 0.obs;

  final int _perPage = 15;
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

  var inputAyatMulaiC = TextEditingController();
  var inputAyatAkhirC = TextEditingController();

  var statusSetoran = ''.obs;

  var catatanController = TextEditingController();

  final formKeyHafalan = GlobalKey<FormState>();
  final formKeyMurajaah = GlobalKey<FormState>();

  final scrollController = ScrollController();
  RxBool isFabVisible = true.obs;

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getUserRole();
    fetchData();
    setupScrollController();

    debounce(searchQuery, (callback) {
      fetchData();
    }, time: const Duration(milliseconds: 700));
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('role') ?? '';
  }

  void resetPagination() {
    currentPage = 1;
    hasMore.value = true;
  }

  void setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreData();
        }
      }
    });
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      resetPagination();

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
        ApiUrl.santri,
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
        ApiUrl.santri,
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

  void onSurahSelected(s.Surah? newSurah) {
    ayatList.clear();

    if (newSurah != null) {
      getProgresAyat(newSurah.id!);
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
      isLoadingProgresHafalan.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http
          .get(
            Uri.parse(ApiUrl.progresHafalan(santriId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
          )
          .timeout(Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        progresHafalan.value = List<ph.Datum>.from(
          data['data'].map((x) => ph.Datum.fromJson(x)),
        );
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getProgresHaflan: $e');
      }
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isLoadingProgresHafalan.value = false;
    }
  }

  void saveHafalan(String santriId) async {
    isSaveLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ustadzId = prefs.getString('roleId');

    // Validasi input
    final jumlahAyat = int.tryParse(inputJumlahAyatController.text) ?? 0;
    if (jumlahAyat <= 0) {
      ToastUtils.showErrorToast('Jumlah ayat harus lebih dari 0');
      isSaveLoading.value = false;
      return;
    }

    // Ambil data surah yang dipilih
    final selectedSurah = selectedSurahHafalan.value?.item;
    if (selectedSurah == null) {
      ToastUtils.showErrorToast('Harap pilih surah terlebih dahulu');
      isSaveLoading.value = false;
      return;
    }

    // Fetch detail hafalan hanya saat save
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiUrl.detailHafalanPerSurahTambah(
                santriId,
                selectedSurah.id.toString(),
              ),
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tempDetailHafalan = dh.DetailHafalan.fromJson(data);

        // Generate ayat IDs berdasarkan logic yang sudah ada
        var ayatIds = [];
        if (tempDetailHafalan.ayat.isNotEmpty) {
          // 1. Cari ayat terakhir yang sudah dihafalkan (checked = true)
          int lastHafalanAyatNumber = 0;
          for (var ayat in tempDetailHafalan.ayat) {
            if (ayat.checked == true) {
              lastHafalanAyatNumber = ayat.nomorAyat ?? 0;
            }
          }

          // 2. Dapatkan daftar ayat yang belum dihafalkan (checked = false)
          List<dh.Ayat> uncheckedAyats = tempDetailHafalan.ayat
              .where((ayat) => ayat.checked == false)
              .toList();

          // 3. Urutkan berdasarkan nomor ayat
          uncheckedAyats.sort(
            (a, b) => (a.nomorAyat ?? 0).compareTo(b.nomorAyat ?? 0),
          );

          // 4. Ambil ayat-ayat berikutnya sesuai jumlah yang diinput
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
              if (ayatsToBeAdded.length >= jumlahAyat) {
                break;
              }
            }
          }

          // 5. Ambil ID dari ayat-ayat yang akan ditambahkan
          ayatIds = ayatsToBeAdded.map((ayat) => ayat.id).toList();
        }

        // Jika tidak ada ayat yang ditemukan
        if (ayatIds.isEmpty) {
          ToastUtils.showErrorToast('Tidak ada ayat yang bisa ditambahkan');
          isSaveLoading.value = false;
          return;
        }

        // Lanjutkan dengan save logic
        await submitHafalan(santriId, ustadzId!, ayatIds);
      } else {
        ToastUtils.showErrorToast('Gagal memuat data ayat');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saveHafalan: $e');
      }
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isSaveLoading.value = false;
    }
  }

  // Helper method untuk submit hafalan
  Future<void> submitHafalan(
    String santriId,
    String ustadzId,
    List ayatIds,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (kDebugMode) {
      print('santriId: $santriId');
      print('ustadzId: $ustadzId');
      print('ayatIds: $ayatIds');
      print(statusSetoran.value);
      print(catatanController.text);
    }

    try {
      final response = await http
          .post(
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
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data);
        }
        Get.back();
        Future.delayed(const Duration(milliseconds: 500), () {
          selectedSurahHafalan.value = null;
          statusSetoran.value = '';
          catatanController.clear();
          inputJumlahAyatController.clear();
          currentAyat.value = 0;
          totalAyat.value = 0;
          progressPercentage.value = 0;
          detailHafalan.value = null;
        });
        ToastUtils.showSuccessToast('Hafalan berhasil ditambahkan');
      } else {
        ToastUtils.showErrorToast('Gagal menambah hafalan');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }

  void saveMurajaah(String santriId) async {
    isSaveLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ustadzId = prefs.getString('roleId');

    // Validasi input
    final ayatMulai = int.tryParse(inputAyatMulaiC.text) ?? 0;
    final ayatAkhir = int.tryParse(inputAyatAkhirC.text) ?? 0;

    if (ayatMulai <= 0 || ayatAkhir <= 0 || ayatAkhir < ayatMulai) {
      ToastUtils.showErrorToast('Input ayat tidak valid');
      isSaveLoading.value = false;
      return;
    }

    // Ambil data surah yang dipilih
    final selectedSurah = selectedSurahMurajaah.value?.item;
    if (selectedSurah == null) {
      ToastUtils.showErrorToast('Harap pilih surah terlebih dahulu');
      isSaveLoading.value = false;
      return;
    }

    // Fetch ayat list
    try {
      final response = await http
          .get(
            Uri.parse(
              ApiUrl.detailHafalanPerSurahMurajaah(
                santriId,
                selectedSurah.id.toString(),
              ),
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ayatData = data['ayat'];
        final tempAyatList = ayatData
            .map((json) => AyatHafalan.fromJson(json))
            .toList();

        // Generate ayat IDs dari input manual
        var ayatIds = [];
        for (int nomorAyat = ayatMulai; nomorAyat <= ayatAkhir; nomorAyat++) {
          final ayatHafalan = tempAyatList.firstWhereOrNull(
            (ayat) => ayat.nomorAyat == nomorAyat,
          );
          if (ayatHafalan != null && ayatHafalan.id != null) {
            ayatIds.add(ayatHafalan.id);
          }
        }

        // Jika tidak ada ayat yang ditemukan
        if (ayatIds.isEmpty) {
          ToastUtils.showErrorToast('Tidak ada ayat yang sesuai dengan input');
          isSaveLoading.value = false;
          return;
        }

        // Lanjutkan dengan save logic
        await submitMurajaah(santriId, ustadzId!, ayatIds);
      } else {
        ToastUtils.showErrorToast('Gagal memuat data ayat');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saveMurajaah: $e');
      }
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isSaveLoading.value = false;
    }
  }

  // Helper method untuk submit
  Future<void> submitMurajaah(
    String santriId,
    String ustadzId,
    List ayatIds,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (kDebugMode) {
      print(santriId);
      print(ustadzId);
      print(ayatIds);
      print(statusSetoran.value);
      print(catatanController.text);
    }

    try {
      final response = await http
          .post(
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
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (kDebugMode) {
          print(data);
        }
        Get.back();
        Future.delayed(const Duration(milliseconds: 500), () {
          selectedSurahMurajaah.value = null;
          statusSetoran.value = '';
          catatanController.clear();
          inputAyatMulaiC.clear();
          inputAyatAkhirC.clear();
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
    }
  }

  void deleteSantriAccount(String santriId) async {
    isLoadingDeleteAccount.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http
          .delete(
            Uri.parse(ApiUrl.deleteSantri(santriId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
          )
          .timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(response.statusCode);
        print(data);
      }
      if (response.statusCode == 200) {
        fetchData();
        Get.back();
        ToastUtils.showSuccessToast('Santri berhasil dihapus');
      } else {
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Gagal menghapus santri');
        }
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
      isLoadingDeleteAccount.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }
}
