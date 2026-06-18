import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/detail_juz.dart';
import 'package:mobile_kalimasada/app/data/repositories/quran_repository.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class DetailJuzController extends GetxController {
  final QuranRepository _quranRepository = Get.find();

  RxBool isLoading = false.obs;
  final juzId = Get.arguments.toString();
  var detailJuz = Rxn<DetailJuz>();

  RxBool isFabVisible = true.obs;

  final listC = ListController();
  final scrollC = ScrollController();
  final searchC = TextEditingController();

  final RxList<dynamic> items = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    getDetailJuz();
  }

  @override
  void onClose() {
    searchC.dispose();
    listC.dispose();
    scrollC.dispose();
    super.onClose();
  }

  Future<void> getDetailJuz() async {
    try {
      isLoading.value = true;
      final detail = await _quranRepository.fetchJuzDetail(juzId);
      detailJuz.value = detail;

      // Flattening logic: Pisahkan Header Surah menjadi item tersendiri
      final List<dynamic> flat = [];
      final ayatList = detail.data?.ayat ?? [];
      for (int i = 0; i < ayatList.length; i++) {
        final ayat = ayatList[i];
        final bool isNewSurah =
            i == 0 || ayat.surah?.nomor != ayatList[i - 1].surah?.nomor;
        if (isNewSurah && ayat.surah != null) {
          flat.add(ayat.surah); // Tambahkan header surah
        }
        flat.add(ayat); // Tambahkan ayat
      }
      items.assignAll(flat);
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToHalaman(int hal) {
    final targetIndex = items.indexWhere(
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
}
