import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/surah.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

class AlquranController extends GetxController {
  var surahList = <Surah>[].obs;
  var filteredSurahList = <Surah>[].obs;
  var searchQuery = ''.obs;
  var isLoadingSurah = false.obs;
  var lastReadSurah = Rxn<Surah>();
  var searchController = TextEditingController();

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    fetchSurahList();

    // Add listener for search query
    ever(searchQuery, (_) => searchSurah());
  }

  void fetchSurahList() async {
    try {
      isLoadingSurah.value = true;

      final response = await http
          .get(
            Uri.parse(ApiUrl.surahList),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> surahsData = data['data'];
        surahList.value = surahsData
            .map((json) => Surah.fromJson(json))
            .toList();
        filteredSurahList.value = List.from(surahList);
      } else {
        ToastUtils.showErrorToast('Gagal memuat surah');
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
      isLoadingSurah.value = false;
    }
  }

  void searchSurah() {
    if (searchQuery.value.isEmpty) {
      filteredSurahList.value = List.from(surahList);
      return;
    }

    final query = searchQuery.value.toLowerCase();
    filteredSurahList.value = surahList.where((surah) {
      return (surah.namaLatin?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void refreshData() {
    fetchSurahList();
  }

  int get searchResultCount => filteredSurahList.length;
  int get totalSurahCount => surahList.length;
}
