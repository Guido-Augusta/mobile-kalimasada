import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/summary_hafalan_juz.dart'
    as juz_model;
import 'package:mobile_kalimasada/app/data/models/summary_hafalan_surah.dart'
    as surah_model;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryHafalanController extends GetxController {
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

  DateTime? _lastErrorShown;

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

  Map<String, String> _buildQueryParams() {
    return {
      'page': currentPage.toString(),
      'limit': _perPage.toString(),
      'status': status.value,
      'tahapHafalan': level.value,
      if (mode.value == 'surah') 'sortByAyat': filterBy.value,
      if (mode.value == 'juz') 'sortByHalaman': filterBy.value,
      'name': searchQuery.value,
      'mode': mode.value,
    };
  }

  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
      'x-platform': 'mobile',
    };
  }

  void _showError(String msg) {
    final now = DateTime.now();
    if (_lastErrorShown == null ||
        now.difference(_lastErrorShown!) > const Duration(seconds: 3)) {
      _lastErrorShown = now;
      ToastUtils.showErrorToast(msg);
    }
  }

  void getSummaryHafalan() async {
    try {
      isLoading.value = true;
      _resetPagination();

      final headers = await _getHeaders();
      final uri = Uri.parse(
        ApiUrl.summaryHafalan,
      ).replace(queryParameters: _buildQueryParams());

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        clearList();
        final data = jsonDecode(response.body);

        if (mode.value == 'surah') {
          final items = List<surah_model.Datum>.from(
            data['data'].map((x) => surah_model.Datum.fromJson(x)),
          );
          if (items.length < _perPage) hasMore.value = false;
          summaryHafalanSurahList.value = items;
        } else {
          final items = List<juz_model.Datum>.from(
            data['data'].map((x) => juz_model.Datum.fromJson(x)),
          );
          if (items.length < _perPage) hasMore.value = false;
          summaryHafalanJuzList.value = items;
        }
      } else {
        _showError('Gagal memuat data');
      }
    } catch (e) {
      _showError('Terjadi kesalahan\nPeriksa koneksi internet Anda');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final headers = await _getHeaders();
      final uri = Uri.parse(
        ApiUrl.summaryHafalan,
      ).replace(queryParameters: _buildQueryParams());

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mode.value == 'surah') {
          final items = List<surah_model.Datum>.from(
            data['data'].map((x) => surah_model.Datum.fromJson(x)),
          );
          if (items.length < _perPage) hasMore.value = false;
          summaryHafalanSurahList.addAll(items);
        } else {
          final items = List<juz_model.Datum>.from(
            data['data'].map((x) => juz_model.Datum.fromJson(x)),
          );
          if (items.length < _perPage) hasMore.value = false;
          summaryHafalanJuzList.addAll(items);
        }
      } else {
        currentPage--;
        _showError('Gagal memuat data');
      }
    } catch (e) {
      currentPage--;
      _showError('Terjadi kesalahan\nPeriksa koneksi internet Anda');
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
}
