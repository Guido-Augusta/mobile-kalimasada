import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/constants/api_url.dart';
import '../../../../data/models/daftar_ustadz.dart';
import '../../../../utils/toast_utils.dart';

class DaftarUstadzController extends GetxController {
  final isLoading = false.obs;
  final isSaveLoading = false.obs;
  final isLoadingDeleteAccount = false.obs;

  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  var ustadzList = <Datum>[].obs;

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
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.ustadz,
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
        ustadzList.clear();
        final data = jsonDecode(response.body);
        final items = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        ustadzList.value = items;
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
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.ustadz,
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
        final newItems = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (newItems.length < _perPage) {
          hasMore.value = false;
        }

        ustadzList.addAll(newItems);
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

  void deleteUstadzAccount(String ustadzId) async {
    isLoadingDeleteAccount.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http
          .delete(
            Uri.parse(ApiUrl.deleteUstadz(ustadzId)),
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
        ToastUtils.showSuccessToast('Ustadz/ah berhasil dihapus');
      } else {
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Gagal menghapus ustadz/ah');
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
