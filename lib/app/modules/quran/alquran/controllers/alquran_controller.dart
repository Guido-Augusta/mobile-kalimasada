import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_surah.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_juz.dart' as juz;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

class AlquranController extends GetxController {
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
  var lastReadSurah = Rxn<Datum>();
  var searchController = TextEditingController();

  DateTime? _lastErrorShown;

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

  Future<void> fetchSurahList() async {
    try {
      isLoadingSurah.value = true;

      final response = await http
          .get(
            Uri.parse(ApiUrl.surahList),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final daftarSurah = DaftarSurah.fromJson(data);
        surahList.value = daftarSurah.data;
        filterData();
      } else {
        ToastUtils.showErrorToast('Gagal memuat surah');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoadingSurah.value = false;
    }
  }

  Future<void> fetchJuzList() async {
    try {
      isLoadingJuz.value = true;

      final response = await http
          .get(
            Uri.parse(ApiUrl.juzList),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final daftarJuz = juz.DaftarJuz.fromJson(data);
        juzList.value = daftarJuz.data;
        filterData();
      } else {
        ToastUtils.showErrorToast('Gagal memuat juz');
      }
    } catch (e) {
      _handleError(e);
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

  void _handleError(dynamic e) {
    final now = DateTime.now();
    if (_lastErrorShown == null ||
        now.difference(_lastErrorShown!) > const Duration(seconds: 3)) {
      _lastErrorShown = now;
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }

  void refreshData() {
    if (selectedTab.value == 0) {
      fetchSurahList();
    } else {
      fetchJuzList();
    }
  }

  int get searchResultCount =>
      selectedTab.value == 0 ? filteredSurahList.length : filteredJuzList.length;

  int get totalCount =>
      selectedTab.value == 0 ? surahList.length : juzList.length;
}
