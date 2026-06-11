import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan_juz.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:flutter/material.dart';

import '../../../../data/repositories/hafalan_repository.dart';
import '../../progres_hafalan/controllers/progres_hafalan_controller.dart';

class DetailHafalanJuzController extends GetxController {
  final HafalanRepository _hafalanRepository = Get.find<HafalanRepository>();

  RxBool isJuzInfoLoading = false.obs;

  // Loading states per mode
  RxBool isLoadingTambah = false.obs;
  RxBool isLoadingMurajaah = false.obs;
  RxBool isLoadingTahsin = false.obs;

  RxBool isSaveLoading = false.obs;

  final juzId = Get.arguments['juzId'].toString();
  final santriId = Get.arguments['santriId'].toString();
  final santriName = Get.arguments['santriName'].toString();

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

  @override
  void onInit() {
    super.onInit();
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

      final data = await _hafalanRepository.fetchDetailHafalanJuz(
        santriId,
        juzId,
      );

      detailTambah.value = data;
      itemsTambah.assignAll(data.surah.expand((s) => [s, ...s.ayat]));
      lastCheckedTambah.value = _getLastCheckedIndex(itemsTambah);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingTambah.value = false;
    }
  }

  Future<void> getDetailMurajaah() async {
    try {
      isLoadingMurajaah.value = true;

      final data = await _hafalanRepository.fetchDetailMurajaahJuz(
        santriId,
        juzId,
      );

      detailMurajaah.value = data;
      itemsMurajaah.assignAll(data.surah.expand((s) => [s, ...s.ayat]));
      lastCheckedMurajaah.value = _getLastCheckedIndex(itemsMurajaah);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingMurajaah.value = false;
    }
  }

  Future<void> getDetailTahsin() async {
    try {
      isLoadingTahsin.value = true;

      final data = await _hafalanRepository.fetchDetailTahsinJuz(
        santriId,
        juzId,
      );

      detailTahsin.value = data;
      itemsTahsin.assignAll(data.surah.expand((s) => [s, ...s.ayat]));
      lastCheckedTahsin.value = _getLastCheckedIndex(itemsTahsin);
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

  Future<void> saveSetoranByHalaman(
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

      final detail = currentDetail;
      if (detail == null) {
        ToastUtils.showErrorToast('Data ayat belum tersedia');
      }

      String status = selectedTab.value == 0
          ? 'TambahHafalan'
          : selectedTab.value == 1
          ? 'Murajaah'
          : 'Tahsin';

      if (kualitas == 'Sangat Baik') {
        kualitas = 'SangatBaik';
      }

      await _hafalanRepository.saveSetoranByHalaman(
        santriId,
        juzId,
        halamanMulai,
        halamanSelesai,
        status,
        kualitas,
        keterangan,
        catatan,
      );

      if (selectedTab.value == 0) {
        await getDetailTambah();
      } else if (selectedTab.value == 1) {
        await getDetailMurajaah();
      } else if (selectedTab.value == 2) {
        await getDetailTahsin();
      }

      if (Get.isRegistered<ProgresHafalanController>()) {
        await Get.find<ProgresHafalanController>().loadData();
      }
      ToastUtils.showSuccessToast('Setoran berhasil disimpan');
      Get.back();
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }
}
