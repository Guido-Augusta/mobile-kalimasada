import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_ayat.dart'
    as model_ayat;
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_halaman.dart'
    as model_halaman;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatHafalanController extends GetxController {
  final santriId = Get.arguments['santriId'];

  var filterStatus = 'TambahHafalan'.obs; // TambahHafalan, Murajaah, Tahsin
  var filterMode = 'ayat'.obs; // ayat, halaman

  var profilSantri = Rxn<model_ayat.Santri>();
  var totalSetoran = 0.obs;

  var riwayatAyatData = <model_ayat.Datum>[].obs;
  var riwayatHalamanData = <model_halaman.Datum>[].obs;

  final int _perPage = 15;
  var currentPage = 1;
  var hasMore = true.obs;

  var isLoading = false.obs;
  var isInitialLoading = true.obs;
  var isLoadingMore = false.obs;

  DateTime? _lastErrorShown;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    _loadInitialData();
    _setupScrollController();
  }

  Future<void> _loadInitialData() async {
    await getRiwayatData();
    isInitialLoading.value = false;
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMoreRiwayat();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getRiwayatData() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      currentPage = 1;
      hasMore.value = true;

      if (filterMode.value == 'ayat') {
        riwayatAyatData.clear();
      } else {
        riwayatHalamanData.clear();
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final response = await _fetchRiwayatFromApi(token, currentPage);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (filterMode.value == 'ayat') {
          final riwayat = model_ayat.RiwayatHafalanAyat.fromJson(data);
          profilSantri.value = riwayat.santri;
          totalSetoran.value = riwayat.pagination?.totalData ?? 0;
          riwayatAyatData.addAll(riwayat.data);
          hasMore.value = riwayat.data.length >= _perPage;
        } else {
          final riwayat = model_halaman.RiwayatHafalanHalaman.fromJson(data);
          if (data['santri'] != null) {
            profilSantri.value = model_ayat.Santri.fromJson(data['santri']);
          }
          totalSetoran.value = riwayat.pagination?.totalData ?? 0;
          riwayatHalamanData.addAll(riwayat.data);
          hasMore.value = riwayat.data.length >= _perPage;
        }
      } else {
        ToastUtils.showErrorToast('Gagal memuat data riwayat');
      }
    } catch (e) {
      _showErrorThrottled();
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        isLoading.value = false;
      });
    }
  }

  Future<void> loadMoreRiwayat() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) {
      return;
    }
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

      final response = await _fetchRiwayatFromApi(token, currentPage);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (filterMode.value == 'ayat') {
          final riwayat = model_ayat.RiwayatHafalanAyat.fromJson(data);
          riwayatAyatData.addAll(riwayat.data);
          hasMore.value = riwayat.data.length >= _perPage;
        } else {
          final riwayat = model_halaman.RiwayatHafalanHalaman.fromJson(data);
          riwayatHalamanData.addAll(riwayat.data);
          hasMore.value = riwayat.data.length >= _perPage;
        }
      } else {
        currentPage--;
        ToastUtils.showErrorToast('Gagal memuat data');
      }
    } catch (e) {
      currentPage--;
      _showErrorThrottled();
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<http.Response> _fetchRiwayatFromApi(String token, int page) async {
    final queryParams = {
      'page': page.toString(),
      'limit': _perPage.toString(),
      'status': filterStatus.value,
      'mode': filterMode.value,
    };

    final uri = Uri.parse(
      ApiUrl.riwayatHafalan(santriId),
    ).replace(queryParameters: queryParams);

    return await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'x-platform': 'mobile',
      },
    );
  }

  void refreshRiwayatHafalan() {
    getRiwayatData();
  }

  void updateFilterStatus(String status) {
    if (isLoading.value) return;
    if (filterStatus.value.toLowerCase() != status.toLowerCase()) {
      filterStatus.value = status;
      getRiwayatData();
    }
  }

  void updateFilterMode(String mode) {
    if (isLoading.value) return;
    if (filterMode.value.toLowerCase() != mode.toLowerCase()) {
      filterMode.value = mode;
      getRiwayatData();
    }
  }

  void deleteRiwayatHafalan({
    required int santriId,
    required String tanggal,
    required String status,
    int? surahId,
    int? juzId,
  }) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final body = <String, dynamic>{
        'santriId': santriId,
        'tanggal': tanggal,
        'status': status,
      };

      if (filterMode.value == 'ayat' && surahId != null) {
        body['surahId'] = surahId;
      } else if (filterMode.value == 'halaman' && juzId != null) {
        body['juzId'] = juzId;
      }

      final response = await http.delete(
        Uri.parse(ApiUrl.deleteRiwayatHafalan),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ToastUtils.showSuccessToast(
          'Riwayat ${getStatusText(status)} berhasil dihapus',
        );
        refreshRiwayatHafalan();
      } else {
        ToastUtils.showErrorToast(
          'Gagal menghapus riwayat ${getStatusText(status)}',
        );
      }
    } catch (e) {
      _showErrorThrottled();
    }
  }

  String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'murajaah':
        return 'Murajaah';
      case 'tambahhafalan':
        return 'Hafalan';
      case 'tahsin':
        return 'Tahsin';
      default:
        return status ?? '-';
    }
  }

  void _showErrorThrottled() {
    final now = DateTime.now();
    if (_lastErrorShown == null ||
        now.difference(_lastErrorShown!) > const Duration(seconds: 3)) {
      _lastErrorShown = now;
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }
}
