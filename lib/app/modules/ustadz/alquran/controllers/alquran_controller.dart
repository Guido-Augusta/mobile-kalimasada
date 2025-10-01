import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/surah.dart';

class AlquranController extends GetxController {
  var surahList = <Surah>[].obs;
  var filteredSurahList = <Surah>[].obs;
  var searchQuery = ''.obs;
  var isLoadingSurah = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var lastReadSurah = Rxn<Surah>();
  var searchController = TextEditingController();

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
      hasError.value = false;
      errorMessage.value = '';

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/alquran/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> surahsData = data['data'];
        surahList.value = surahsData
            .map((json) => Surah.fromJson(json))
            .toList();
        filteredSurahList.value = List.from(surahList);
      } else {
        hasError.value = true;
        errorMessage.value = 'Failed to load surahs: ${response.statusCode}';
        Get.snackbar(
          'Error',
          'Failed to load surahs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An error occurred: $e';
      Get.snackbar(
        'Error',
        'An error occurred while loading surahs',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
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
      return (surah.namaLatin?.toLowerCase().contains(query) ?? false) ||
          (surah.nama?.toLowerCase().contains(query) ?? false) ||
          (surah.nomor?.toString().contains(query) ?? false) ||
          (surah.arti?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void refreshData() {
    fetchSurahList();
  }

  int get searchResultCount => filteredSurahList.length;
  int get totalSurahCount => surahList.length;
}
