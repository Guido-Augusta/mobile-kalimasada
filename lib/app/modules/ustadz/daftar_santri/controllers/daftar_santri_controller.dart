import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart' as ds;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaftarSantriController extends GetxController {
  var userRole = ''.obs;
  bool get isAdmin => userRole.value == 'admin';

  final isLoading = false.obs;
  final isLoadingDeleteAccount = false.obs;

  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  var tahapHafalan = 'level1'.obs;

  var santriList = <ds.Datum>[].obs;

  final int _perPage = 15;
  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  final scrollController = ScrollController();
  RxBool isFabVisible = true.obs;

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getUserRole();
    fetchData();
    setupScrollController();

    debounce(searchQuery, (callback) {
      fetchData();
    }, time: const Duration(milliseconds: 700));
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getUserRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('role') ?? '';
  }

  void resetPagination() {
    currentPage = 1;
    hasMore.value = true;
  }

  void setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreData();
        }
      }
    });
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      resetPagination();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'tahapHafalan': tahapHafalan.value,
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.santri,
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
        santriList.clear();
        final data = jsonDecode(response.body);
        final items = List<ds.Datum>.from(
          data['data'].map((x) => ds.Datum.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        santriList.value = items;
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
      isLoading.value = false;
    }
  }

  void changeTahapHafalan(String tahapHafalan) {
    if (tahapHafalan.toLowerCase() == this.tahapHafalan.value.toLowerCase()) {
      return;
    }
    this.tahapHafalan.value = tahapHafalan;
    santriList.clear();
    fetchData();
  }

  void loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

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

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'tahapHafalan': tahapHafalan.value,
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.santri,
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
        final newItems = List<ds.Datum>.from(
          data['data'].map((x) => ds.Datum.fromJson(x)),
        );

        if (newItems.length < _perPage) {
          hasMore.value = false;
        }

        santriList.addAll(newItems);
      } else {
        currentPage--; // Revert page on error
        ToastUtils.showErrorToast('Gagal memuat data tambahan');
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

  void deleteSantriAccount(String santriId) async {
    isLoadingDeleteAccount.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http
          .delete(
            Uri.parse(ApiUrl.deleteSantri(santriId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
          )
          .timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(response.statusCode);
        print(data);
      }
      if (response.statusCode == 200) {
        fetchData();
        Get.back();
        ToastUtils.showSuccessToast('Santri berhasil dihapus');
      } else {
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Gagal menghapus santri');
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
      isLoadingDeleteAccount.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }
}
