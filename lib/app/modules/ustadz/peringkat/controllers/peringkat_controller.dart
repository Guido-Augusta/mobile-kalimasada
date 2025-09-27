import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/peringkat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeringkatController extends GetxController {
  var isLoading = false.obs;
  var peringkat = <Datum>[].obs;

  var selectedTahap = 'level1'.obs;
  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  final int _perPage = 10;
  var currentPage = 1;
  var hasMore = true;
  var isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    getPeringkat();
  }

  void _resetPagination() {
    currentPage = 1;
    hasMore = true;
    peringkat.clear();
  }

  Future<void> getPeringkat() async {
    // http://10.0.2.2:5000/api/santri/peringkat?page=1&limit=10&search=guido&tahapHafalan=level1

    _resetPagination();
    isLoading.value = true;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/santri/peringkat?page=$currentPage&limit=$_perPage&search=${searchQuery.value}&tahapHafalan=${selectedTahap.value}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        peringkat.value = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (peringkat.length < _perPage) {
          hasMore = false;
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load santri detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat peringkat santri');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreData() async {
    if (isLoadingMore.value || !hasMore) return;

    isLoadingMore.value = true;
    currentPage++;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.get(
          Uri.parse(
            'http://10.0.2.2:5000/api/santri/peringkat?page=$currentPage&limit=$_perPage&search=${searchQuery.value}&tahapHafalan=${selectedTahap.value}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-platform': 'mobile',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newItems = List<Datum>.from(
            data['data'].map((x) => Datum.fromJson(x)),
          );
          peringkat.addAll(newItems);

          if (newItems.length < _perPage) {
            hasMore = false;
          }
        } else {
          currentPage--;
          Get.snackbar('Error', 'Gagal memuat data tambahan');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat data tambahan');
    } finally {
      isLoadingMore.value = false;
    }
  }
}
