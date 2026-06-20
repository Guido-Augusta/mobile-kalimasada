import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/summary_hafalan_juz.dart'
    as juz_model;
import 'package:mobile_kalimasada/app/data/models/summary_hafalan_surah.dart'
    as surah_model;
import 'package:mobile_kalimasada/app/data/repositories/hafalan_repository.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/exceptions/app_exception.dart';

class SummaryHafalanController extends GetxController {
  final HafalanRepository _hafalanRepository = Get.find<HafalanRepository>();
  var isLoading = false.obs;

  var searchQuery = ''.obs;
  final appliedSearchQuery = ''.obs;
  var searchController = TextEditingController();

  /// mode: 'surah' | 'juz'
  var mode = 'surah'.obs;

  var status = 'tambahHafalan'.obs;
  var level = 'level1'.obs;
  var filterBy = 'desc'.obs; // asc/desc only for tambahHafalan

  final int _perPage = 15;
  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  var summaryHafalanSurahList = <surah_model.Datum>[].obs;
  var summaryHafalanJuzList = <juz_model.Datum>[].obs;

  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    getSummaryHafalan();
    _setupScrollController();

    debounce(searchQuery, (callback) {
      appliedSearchQuery.value = searchQuery.value;
      getSummaryHafalan();
    }, time: const Duration(milliseconds: 700));
  }

  void switchMode(String newMode) {
    if (mode.value == newMode) return;
    mode.value = newMode;
    clearList();
    getSummaryHafalan();
  }

  void updateFilterBy() {
    filterBy.value = filterBy.value == 'asc' ? 'desc' : 'asc';
    getSummaryHafalan();
  }

  void clearList() {
    summaryHafalanSurahList.clear();
    summaryHafalanJuzList.clear();
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

  void getSummaryHafalan() async {
    try {
      isLoading.value = true;
      _resetPagination();

      if (mode.value == 'surah') {
        final items = await _hafalanRepository.fetchSummaryHafalanSurah(
          page: currentPage,
          limit: _perPage,
          status: status.value,
          tahapHafalan: level.value,
          sortByAyat: filterBy.value,
          name: searchQuery.value,
        );
        clearList();
        if (items.length < _perPage) hasMore.value = false;
        summaryHafalanSurahList.value = items;
      } else {
        final items = await _hafalanRepository.fetchSummaryHafalanJuz(
          page: currentPage,
          limit: _perPage,
          status: status.value,
          tahapHafalan: level.value,
          sortByHalaman: filterBy.value,
          name: searchQuery.value,
        );
        clearList();
        if (items.length < _perPage) hasMore.value = false;
        summaryHafalanJuzList.value = items;
      }
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      if (mode.value == 'surah') {
        final items = await _hafalanRepository.fetchSummaryHafalanSurah(
          page: currentPage,
          limit: _perPage,
          status: status.value,
          tahapHafalan: level.value,
          sortByAyat: filterBy.value,
          name: searchQuery.value,
        );
        if (items.length < _perPage) hasMore.value = false;
        summaryHafalanSurahList.addAll(items);
      } else {
        final items = await _hafalanRepository.fetchSummaryHafalanJuz(
          page: currentPage,
          limit: _perPage,
          status: status.value,
          tahapHafalan: level.value,
          sortByHalaman: filterBy.value,
          name: searchQuery.value,
        );
        if (items.length < _perPage) hasMore.value = false;
        summaryHafalanJuzList.addAll(items);
      }
    } on AppException catch (e) {
      currentPage--;
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      currentPage--;
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingMore.value = false;
    }
  }

  String getTahapanLabel(String tahapan) {
    switch (tahapan.toLowerCase()) {
      case 'level1':
        return 'Level 1 - Juz 30';
      case 'level2':
        return 'Level 2 - Surah Pilihan';
      case 'level3':
        return 'Level 3 - Juz 1-29';
      default:
        return 'Tidak ada tahapan';
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
