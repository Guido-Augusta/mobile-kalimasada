import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatHafalanController extends GetxController {
  String? userRole;
  final santriId = Get.arguments['santriId'];
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var filterType = 'TambahHafalan'.obs; // TambahHafalan or Murajaah
  var riwayatHafalan = Rxn<RiwayatHafalan>();
  var allRiwayatData = <Datum>[].obs;

  final int _perPage = 10;
  var currentPage = 1;
  var hasMore = true.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userRole = prefs.getString('role');
    getRiwayatHafalan(santriId);
    _setupScrollController();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreRiwayatHafalan();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void getRiwayatHafalan(String id) async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'No authentication token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/riwayat/$id?page=$currentPage&limit=$_perPage&status=${filterType.value}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final riwayat = RiwayatHafalan.fromJson(data);
        riwayatHafalan.value = riwayat;
        allRiwayatData.value = riwayat.data;

        // Check if there are more pages
        hasMore.value = riwayat.data.length >= _perPage;
      } else {
        Get.snackbar(
          'Error',
          'Failed to load riwayat hafalan: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getRiwayatHafalan: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreRiwayatHafalan() async {
    if (!hasMore.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    currentPage++;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'No authentication token found');
      isLoadingMore.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/riwayat/$santriId?page=$currentPage&limit=$_perPage&status=${filterType.value}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final riwayat = RiwayatHafalan.fromJson(data);

        // Add new data to existing list
        allRiwayatData.addAll(riwayat.data);

        // Check if there are more pages
        hasMore.value = riwayat.data.length >= _perPage;
        print('More riwayat hafalan loaded: ${riwayat.data.length} entries');
      } else {
        Get.snackbar(
          'Error',
          'Failed to load more riwayat hafalan: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in loadMoreRiwayatHafalan: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void refreshRiwayatHafalan() {
    currentPage = 1;
    hasMore.value = true;
    allRiwayatData.clear();
    getRiwayatHafalan(santriId);
  }

  void updateFilter(String type) {
    if (filterType.value.toLowerCase() != type.toLowerCase()) {
      filterType.value = type;
    }
    refreshRiwayatHafalan();
  }

  void deleteRiwayatHafalan(
    int santriId,
    int surahId,
    String tanggal,
    String status,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'No authentication token found');
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:5000/api/hafalan/riwayat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'surahId': surahId,
          'tanggal': tanggal,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Riwayat hafalan berhasil dihapus');
        refreshRiwayatHafalan();
      } else {
        Get.snackbar(
          'Error',
          'Gagal menghapus riwayat hafalan: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in deleteRiwayatHafalan: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    }
  }
}
