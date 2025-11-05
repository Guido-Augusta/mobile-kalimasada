import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
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

  DateTime? _lastErrorShown;

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
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

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
        ToastUtils.showErrorToast('Gagal memuat data');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void loadMoreRiwayatHafalan() async {
    if (!hasMore.value || isLoadingMore.value) return;
    try {
      isLoadingMore.value = true;
      currentPage++;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

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
      } else {
        ToastUtils.showErrorToast('Gagal memuat data');
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
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

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
        ToastUtils.showSuccessToast('Riwayat hafalan berhasil dihapus');

        refreshRiwayatHafalan();
      } else {
        ToastUtils.showErrorToast('Gagal menghapus riwayat hafalan');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }
}
