import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/services/auth_service.dart';

import '../../../../data/constants/api_url.dart';
import '../../../../data/models/daftar_ortu.dart';
import '../../../../utils/toast_utils.dart';

class DaftarOrtuController extends GetxController {
  final token = AuthService.to.token.value;

  final isLoading = false.obs;
  final isSaveLoading = false.obs;
  final isLoadingDeleteAccount = false.obs;

  var searchQuery = ''.obs;
  var searchController = TextEditingController();

  var ortuList = <Datum>[].obs;

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

      if (token.isEmpty) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'search': searchQuery.value,
      };

      final uri = Uri.parse(ApiUrl.ortu).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        ortuList.clear();
        final data = jsonDecode(response.body);
        final items = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        ortuList.value = items;
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

      if (token.isEmpty) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'search': searchQuery.value,
      };

      final uri = Uri.parse(ApiUrl.ortu).replace(queryParameters: queryParams);

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

        ortuList.addAll(newItems);
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

  void deleteOrtuAccount(String ortuId) async {
    isLoadingDeleteAccount.value = true;
    try {
      final response = await http
          .delete(
            Uri.parse(ApiUrl.deleteOrtu(ortuId)),
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
        ToastUtils.showSuccessToast('Ortu berhasil dihapus');
      } else {
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Gagal menghapus ortu');
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
