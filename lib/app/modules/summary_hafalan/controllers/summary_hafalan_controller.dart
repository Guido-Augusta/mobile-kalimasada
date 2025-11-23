import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/summary_hafalan.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryHafalanController extends GetxController {
  var isLoading = false.obs;

  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  var status = 'tambahHafalan'.obs;
  var level = 'level1'.obs;
  var filterBy = 'desc'.obs;

  final int _perPage = 15;
  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  var summaryHafalanList = <Datum>[].obs;

  final scrollController = ScrollController();

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getSummaryHafalan();
    _setupScrollController();
  }

  void updateFilterBy() {
    filterBy.value = filterBy.value == 'asc' ? 'desc' : 'asc';
    getSummaryHafalan();
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

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/all-santri/latest?page=$currentPage&limit=$_perPage&status=${status.value}&tahapHafalan=${level.value}&sortByAyat=${filterBy.value}&name=${searchQuery.value}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        summaryHafalanList.clear();

        final data = jsonDecode(response.body);
        final items = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        summaryHafalanList.value = items;
      } else {
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Gagal memuat data');
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
      isLoading.value = false;
    }
  }

  void loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/all-santri/latest?page=$currentPage&limit=$_perPage&status=${status.value}&tahapHafalan=${level.value}&sortByAyat=${filterBy.value}&name=${searchQuery.value}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        summaryHafalanList.addAll(items);
      } else {
        currentPage--; // Revert page on error
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Gagal memuat data');
        }
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

  String getTahapanLabel(String tahapan) {
    if (tahapan == 'level1') {
      return 'level 1';
    } else if (tahapan == 'level2') {
      return 'level 2';
    } else if (tahapan == 'level3') {
      return 'level 3';
    } else {
      return 'Tidak ada tahapan';
    }
  }
}
