import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/summary_hafalan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SummaryHafalanController extends GetxController {
  var isLoading = false.obs;
  var searchQuery = ''.obs;
  var status = 'tambahHafalan'.obs;
  var level = 'level1'.obs;
  var filterBy = 'desc'.obs;

  final int _perPage = 10;
  var currentPage = 1;
  var hasMore = true;
  var isLoadingMore = false;

  var summaryHafalanList = <Datum>[].obs;

  @override
  void onInit() {
    super.onInit();
    getSummaryHafalan();
  }

  void updateStatusFilter(String type) {
    if (status.value.toLowerCase() != type.toLowerCase()) {
      status.value = type;
    }
    getSummaryHafalan();
  }

  void updateFilterBy() {
    filterBy.value = filterBy.value == 'asc' ? 'desc' : 'asc';
    getSummaryHafalan();
  }

  void _resetPagination() {
    currentPage = 1;
    hasMore = true;
    summaryHafalanList.clear();
  }

  void getSummaryHafalan() async {
    try {
      isLoading.value = true;
      _resetPagination();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.snackbar('Error', 'No authentication token found');
        return;
      }

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
          hasMore = false;
        }

        summaryHafalanList.value = items;
      } else {
        Get.snackbar(
          'Error',
          'Gagal mendapatkan data',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreData() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    currentPage++;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        Get.snackbar('Error', 'No authentication token found');
        return;
      }

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
          hasMore = false;
        }

        summaryHafalanList.addAll(items);
      } else {
        Get.snackbar(
          'Error',
          'Gagal mendapatkan data',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memuat data',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    } finally {
      isLoadingMore = false;
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
