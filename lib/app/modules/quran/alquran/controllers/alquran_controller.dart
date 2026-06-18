import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_surah.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_juz.dart' as juz;
import 'package:mobile_kalimasada/app/data/repositories/quran_repository.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/exceptions/app_exception.dart';

class AlquranController extends GetxController {
  final QuranRepository _quranRepository = Get.find();

  // Surah Data
  var surahList = <Datum>[].obs;
  var filteredSurahList = <Datum>[].obs;
  var isLoadingSurah = false.obs;

  // Juz Data
  var juzList = <juz.Datum>[].obs;
  var filteredJuzList = <juz.Datum>[].obs;
  var isLoadingJuz = false.obs;

  // UI State
  var selectedTab = 0.obs; // 0 for Surah, 1 for Juz
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchSurahList();
    fetchJuzList();

    // Add listener for search query
    ever(searchQuery, (_) => filterData());
    // Add listener for tab changes to re-filter
    ever(selectedTab, (_) => filterData());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchSurahList() async {
    try {
      isLoadingSurah.value = true;
      final daftarSurah = await _quranRepository.fetchSurahList();
      surahList.value = daftarSurah.data;
      filterData();
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingSurah.value = false;
    }
  }

  Future<void> fetchJuzList() async {
    try {
      isLoadingJuz.value = true;
      final daftarJuz = await _quranRepository.fetchJuzList();
      juzList.value = daftarJuz.data;
      filterData();
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingJuz.value = false;
    }
  }

  void filterData() {
    final query = searchQuery.value.toLowerCase();

    if (selectedTab.value == 0) {
      // Filter Surah
      if (query.isEmpty) {
        filteredSurahList.value = List.from(surahList);
      } else {
        filteredSurahList.value = surahList.where((surah) {
          return (surah.namaLatin?.toLowerCase().contains(query) ?? false) ||
              (surah.nomor.toString().contains(query));
        }).toList();
      }
    } else {
      // Filter Juz
      if (query.isEmpty) {
        filteredJuzList.value = List.from(juzList);
      } else {
        filteredJuzList.value = juzList.where((j) {
          return j.juz.toString().contains(query) ||
              (j.mulaiDari?.surah?.namaLatin?.toLowerCase().contains(query) ??
                  false);
        }).toList();
      }
    }
  }

  void refreshData() {
    if (selectedTab.value == 0) {
      fetchSurahList();
    } else {
      fetchJuzList();
    }
  }

  int get searchResultCount => selectedTab.value == 0
      ? filteredSurahList.length
      : filteredJuzList.length;

  int get totalCount =>
      selectedTab.value == 0 ? surahList.length : juzList.length;
}
