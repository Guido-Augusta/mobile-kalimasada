import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan_juz.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:flutter/material.dart';

import '../../../ustadz/progres_hafalan/controllers/progres_hafalan_controller.dart';

class DetailHafalanJuzController extends GetxController {
  RxBool isJuzInfoLoading = false.obs;

  // Loading states per mode
  RxBool isLoadingTambah = false.obs;
  RxBool isLoadingMurajaah = false.obs;
  RxBool isLoadingTahsin = false.obs;

  RxBool isSaveLoading = false.obs;

  late String santriId;
  late String juzId;
  // We don't have santriName from arguments possibly if it only passed juzId and santriId,
  // let's grab it or default to something
  String santriName = 'Santri';

  // Data per mode (Original)
  var detailTambah = Rxn<DetailHafalanJuz>();
  var detailMurajaah = Rxn<DetailHafalanJuz>();
  var detailTahsin = Rxn<DetailHafalanJuz>();

  // Data per mode (Flattened for UI)
  final RxList<dynamic> itemsTambah = <dynamic>[].obs;
  final RxList<dynamic> itemsMurajaah = <dynamic>[].obs;
  final RxList<dynamic> itemsTahsin = <dynamic>[].obs;

  RxBool isFabVisible = true.obs;
  RxBool isActionBarVisible = true.obs;

  final listC = ListController();
  final scrollC = ScrollController();
  final searchC = TextEditingController();

  // Last checked per mode
  RxInt lastCheckedTambah = 0.obs;
  RxInt lastCheckedMurajaah = 0.obs;
  RxInt lastCheckedTahsin = 0.obs;

  // 0 = Hafalan, 1 = Murajaah, 2 = Tahsin
  RxInt selectedTab = 0.obs;

  bool get isCurrentLoading {
    if (selectedTab.value == 0) return isLoadingTambah.value;
    if (selectedTab.value == 1) return isLoadingMurajaah.value;
    return isLoadingTahsin.value;
  }

  DetailHafalanJuz? get currentDetail {
    if (selectedTab.value == 0) return detailTambah.value;
    if (selectedTab.value == 1) return detailMurajaah.value;
    return detailTahsin.value;
  }

  List<dynamic> get currentItems {
    if (selectedTab.value == 0) return itemsTambah;
    if (selectedTab.value == 1) return itemsMurajaah;
    return itemsTahsin;
  }

  int get currentLastChecked {
    if (selectedTab.value == 0) return lastCheckedTambah.value;
    if (selectedTab.value == 1) return lastCheckedMurajaah.value;
    return lastCheckedTahsin.value;
  }

  int get firstHalaman {
    final detail = currentDetail;
    if (detail == null || detail.surah.isEmpty) return 0;
    return detail.surah.first.ayat.first.halaman ?? 0;
  }

  int get lastHalaman {
    final detail = currentDetail;
    if (detail == null || detail.surah.isEmpty) return 0;
    return detail.surah.last.ayat.last.halaman ?? 0;
  }

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      santriId = args['santriId'].toString();
      juzId = args['juzId'].toString();
      if (args.containsKey('santriName')) {
        santriName = args['santriName'].toString();
      }
    }

    getDetailTambah();
  }

  @override
  void onClose() {
    searchC.dispose();
    scrollC.dispose();
    listC.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    // reset scroll to top on tab change
    if (scrollC.hasClients) {
      scrollC.jumpTo(0);
    }
    // Lazy load
    if (index == 1 && detailMurajaah.value == null) {
      getDetailMurajaah();
    } else if (index == 2 && detailTahsin.value == null) {
      getDetailTahsin();
    }
    isFabVisible.value = true;
    isActionBarVisible.value = true;
  }

  int _getLastCheckedIndex(List<dynamic> flatItems) {
    int idx = flatItems.lastIndexWhere(
      (item) => item is Ayat && item.checked == true,
    );
    return idx == -1 ? 0 : idx;
  }

  int getAyatCount(List<SurahElement> surahs) {
    int count = 0;
    for (var s in surahs) {
      count += s.ayat.length;
    }
    return count;
  }

  int getCheckedAyatCount(List<SurahElement> surahs) {
    int count = 0;
    for (var s in surahs) {
      count += s.ayat
          .where(
            (a) => a.checked == true && a.keterangan?.toLowerCase() == 'lanjut',
          )
          .length;
    }
    return count;
  }

  Future<void> getDetailTambah() async {
    try {
      isLoadingTambah.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerJuzTambah(santriId, juzId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detail = DetailHafalanJuz.fromJson(data);
        detailTambah.value = detail;
        itemsTambah.assignAll(detail.surah.expand((s) => [s, ...s.ayat]));
        lastCheckedTambah.value = _getLastCheckedIndex(itemsTambah);
      } else {
        ToastUtils.showErrorToast('Gagal memuat hafalan juz');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Periksa koneksi internet Anda');
    } finally {
      isLoadingTambah.value = false;
    }
  }

  Future<void> getDetailMurajaah() async {
    try {
      isLoadingMurajaah.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerJuzMurajaah(santriId, juzId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detail = DetailHafalanJuz.fromJson(data);
        detailMurajaah.value = detail;
        itemsMurajaah.assignAll(detail.surah.expand((s) => [s, ...s.ayat]));
        lastCheckedMurajaah.value = _getLastCheckedIndex(itemsMurajaah);
      } else {
        ToastUtils.showErrorToast('Gagal memuat murajaah juz');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Periksa koneksi internet Anda');
    } finally {
      isLoadingMurajaah.value = false;
    }
  }

  Future<void> getDetailTahsin() async {
    try {
      isLoadingTahsin.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerJuzTahsin(santriId, juzId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final detail = DetailHafalanJuz.fromJson(data);
        detailTahsin.value = detail;
        itemsTahsin.assignAll(detail.surah.expand((s) => [s, ...s.ayat]));
        lastCheckedTahsin.value = _getLastCheckedIndex(itemsTahsin);
      } else {
        ToastUtils.showErrorToast('Gagal memuat tahsin juz');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Periksa koneksi internet Anda');
    } finally {
      isLoadingTahsin.value = false;
    }
  }

  void scrollToHalaman(int hal) {
    int targetIndex = currentItems.indexWhere(
      (item) => item is Ayat && item.halaman == hal,
    );

    if (targetIndex != -1) {
      if (listC.isAttached) {
        listC.animateToItem(
          index: targetIndex,
          scrollController: scrollC,
          alignment: 0,
          duration: (estimatedDistance) => const Duration(milliseconds: 800),
          curve: (estimatedDistance) => Curves.easeInOutCubic,
        );
      }
    } else {
      ToastUtils.showErrorToast('Halaman $hal tidak ditemukan di juz ini');
    }
  }

  Future<bool> saveSetoranByHalaman(
    int santriId,
    int juzId,
    int halamanMulai,
    int halamanSelesai,
    String? kualitas,
    String keterangan,
    String? catatan,
  ) async {
    try {
      isSaveLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final detail = currentDetail;
      if (detail == null) {
        ToastUtils.showErrorToast('Data ayat belum tersedia');
        return false;
      }

      String status = selectedTab.value == 0
          ? 'TambahHafalan'
          : selectedTab.value == 1
          ? 'Murajaah'
          : 'Tahsin';

      if (kualitas == 'Sangat Baik') {
        kualitas = 'SangatBaik';
      }

      final response = await http.post(
        Uri.parse(ApiUrl.saveSetoranByHalaman),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'juzId': juzId,
          'halamanAwal': halamanMulai,
          'halamanAkhir': halamanSelesai,
          'status': status,
          'kualitas': kualitas ?? 'Baik',
          'keterangan': keterangan,
          'catatan': catatan ?? '',
        }),
      );

      if (response.statusCode == 200) {
        ToastUtils.showSuccessToast('Setoran berhasil disimpan');
        if (selectedTab.value == 0) {
          getDetailTambah();
        } else if (selectedTab.value == 1) {
          getDetailMurajaah();
        } else if (selectedTab.value == 2) {
          getDetailTahsin();
        }

        if (Get.isRegistered<ProgresHafalanController>()) {
          await Future.wait([
            Get.find<ProgresHafalanController>().getProgresHafalanSurah(
              santriId.toString(),
            ),
            Get.find<ProgresHafalanController>().getProgresHafalanJuz(
              santriId.toString(),
            ),
          ]);
        }
        return true;
      } else {
        ToastUtils.showErrorToast('Gagal menyimpan setoran');
        return false;
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
      return false;
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        isSaveLoading.value = false;
      });
    }
  }
}
