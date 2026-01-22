import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiwayatHafalanController extends GetxController {
  String? userRole;
  final santriId = Get.arguments['santriId'];
  var filterType = 'TambahHafalan'.obs; // TambahHafalan or Murajaah
  var profilSantri = Rxn<Santri>();
  var totalSetoranHafalan = 0;
  var totalSetoranMurajaah = 0;
  var riwayatHafalanData = <Datum>[].obs;
  var riwayatMurajaahData = <Datum>[].obs;

  final int _perPage = 15;
  var currentPageHafalan = 1;
  var currentPageMurajaah = 1;
  var hasMoreHafalan = true.obs;
  var hasMoreMurajaah = true.obs;

  var isLoading = false.obs;
  var isLoadingMoreHafalan = false.obs;
  var isLoadingMoreMurajaah = false.obs;

  DateTime? _lastErrorShown;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userRole = prefs.getString('role');
    _loadInitialData();
    _setupScrollController();
  }

  Future<void> _loadInitialData() async {
    await getRiwayatData(santriId);
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (filterType.value.toLowerCase() == 'tambahhafalan' &&
            hasMoreHafalan.value &&
            !isLoadingMoreHafalan.value) {
          loadMoreRiwayatHafalan();
        }
        if (filterType.value.toLowerCase() == 'murajaah' &&
            hasMoreMurajaah.value &&
            !isLoadingMoreMurajaah.value) {
          loadMoreRiwayatMurajaah();
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getRiwayatData(String santriId) async {
    try {
      isLoading.value = true;
      currentPageHafalan = 1;
      currentPageMurajaah = 1;
      hasMoreHafalan.value = true;
      hasMoreMurajaah.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      // Buat 2 request secara paralel
      final hafalanFuture = _getRiwayatByStatus(
        santriId,
        token,
        'TambahHafalan',
        currentPageHafalan,
      );
      final murajaahFuture = _getRiwayatByStatus(
        santriId,
        token,
        'Murajaah',
        currentPageMurajaah,
      );

      // Tunggu kedua request selesai
      final results = await Future.wait([hafalanFuture, murajaahFuture]);

      final hafalanResponse = results[0];
      final murajaahResponse = results[1];

      // Proses response hafalan
      if (hafalanResponse.statusCode == 200) {
        final data = jsonDecode(hafalanResponse.body);
        final riwayat = RiwayatHafalan.fromJson(data);
        profilSantri.value = riwayat.santri;
        totalSetoranHafalan = riwayat.pagination?.totalData ?? 0;
        riwayatHafalanData.clear();
        riwayatHafalanData.addAll(riwayat.data);
        hasMoreHafalan.value = riwayat.data.length >= _perPage;
      } else {
        ToastUtils.showErrorToast('Gagal memuat data hafalan');
      }

      // Proses response murajaah
      if (murajaahResponse.statusCode == 200) {
        final data = jsonDecode(murajaahResponse.body);
        final riwayat = RiwayatHafalan.fromJson(data);
        totalSetoranMurajaah = riwayat.pagination?.totalData ?? 0;
        riwayatMurajaahData.clear();
        riwayatMurajaahData.addAll(riwayat.data);
        hasMoreMurajaah.value = riwayat.data.length >= _perPage;
      } else {
        ToastUtils.showErrorToast('Gagal memuat data murajaah');
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
      Future.delayed(const Duration(milliseconds: 300), () {
        isLoading.value = false;
      });
    }
  }

  // Helper function untuk membuat request berdasarkan status
  Future<http.Response> _getRiwayatByStatus(
    String santriId,
    String token,
    String status,
    int page,
  ) async {
    final queryParams = {
      'page': page.toString(),
      'limit': _perPage.toString(),
      'status': status,
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

  void loadMoreRiwayatHafalan() async {
    if (!hasMoreHafalan.value ||
        isLoadingMoreHafalan.value ||
        isLoading.value) {
      return;
    }
    try {
      isLoadingMoreHafalan.value = true;
      currentPageHafalan++;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': currentPageHafalan.toString(),
        'limit': _perPage.toString(),
        'status': 'TambahHafalan',
      };

      final uri = Uri.parse(
        ApiUrl.riwayatHafalan(santriId),
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
        riwayatHafalanData.addAll(riwayat.data);

        // Check if there are more pages
        hasMoreHafalan.value = riwayat.data.length >= _perPage;
      } else {
        currentPageHafalan--;
        ToastUtils.showErrorToast('Gagal memuat data');
      }
    } catch (e) {
      currentPageHafalan--;
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isLoadingMoreHafalan.value = false;
    }
  }

  void loadMoreRiwayatMurajaah() async {
    if (!hasMoreMurajaah.value ||
        isLoadingMoreMurajaah.value ||
        isLoading.value) {
      return;
    }
    try {
      isLoadingMoreMurajaah.value = true;
      currentPageMurajaah++;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': currentPageMurajaah.toString(),
        'limit': _perPage.toString(),
        'status': 'Murajaah',
      };

      final uri = Uri.parse(
        ApiUrl.riwayatHafalan(santriId),
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
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
        riwayatMurajaahData.addAll(riwayat.data);

        // Check if there are more pages
        hasMoreMurajaah.value = riwayat.data.length >= _perPage;
      } else {
        currentPageMurajaah--;
        ToastUtils.showErrorToast('Gagal memuat data');
      }
    } catch (e) {
      currentPageMurajaah--;
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isLoadingMoreMurajaah.value = false;
    }
  }

  void refreshRiwayatHafalan() {
    getRiwayatData(santriId);
  }

  void updateFilter(String type) {
    if (isLoading.value) return;

    if (filterType.value.toLowerCase() != type.toLowerCase()) {
      filterType.value = type;
    }
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
        Uri.parse(ApiUrl.deleteRiwayatHafalan),
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
