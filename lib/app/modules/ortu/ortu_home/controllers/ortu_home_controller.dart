import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart' as o;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

class OrtuHomeController extends GetxController {
  // ── State Variables ────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final isLoadingChildren = true.obs;
  final isLoadingLogout = false.obs;
  final isLoadingMore = false.obs;

  final fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  final ortu = Rxn<o.Ortu>();
  final childrenList = RxList<s.Santri>();

  // ── Pagination & Search ───────────────────────────────────────────────────
  final int _perPage = 10;
  int currentPage = 1;
  final hasMore = true.obs;

  final searchQuery = ''.obs;
  final appliedSearchQuery = ''.obs;
  final searchController = TextEditingController();
  final scrollController = ScrollController();

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getOrtu();
    _setupScrollController();
    _setupSearchDebounce();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreChildrenData();
        }
      }
    });
  }

  void _setupSearchDebounce() {
    debounce(searchQuery, (callback) {
      appliedSearchQuery.value = searchQuery.value;
      fetchChildrenData();
    }, time: const Duration(milliseconds: 700));
  }

  void resetPagination() {
    currentPage = 1;
    hasMore.value = true;
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getOrtu() async {
    try {
      isLoading.value = true;
      final token = AuthService.to.token.value;
      final ortuId = AuthService.to.roleId.value;

      final response = await get(
        Uri.parse(ApiUrl.ortuDetail(ortuId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      ).timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ortu.value = o.Ortu.fromJson(data['data']);
        if (ortu.value?.fotoProfil?.isNotEmpty == true) {
          fotoProfil.value = getImageUrl(ortu.value!.fotoProfil!);
        }

        fetchChildrenData();
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data');
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

  Future<void> fetchChildrenData() async {
    try {
      isLoadingChildren.value = true;
      resetPagination();

      final token = AuthService.to.token.value;
      final ortuId = AuthService.to.roleId.value;

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'ortuId': ortuId,
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.santri,
      ).replace(queryParameters: queryParams);

      final response = await get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        childrenList.clear();
        final data = jsonDecode(response.body);
        final items = List<s.Santri>.from(
          data['data'].map((x) => s.Santri.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        childrenList.assignAll(items);
      } else {
        ToastUtils.showErrorToast('Gagal memuat data anak');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan memuat data anak');
    } finally {
      isLoadingChildren.value = false;
    }
  }

  void loadMoreChildrenData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final token = AuthService.to.token.value;
      final ortuId = AuthService.to.roleId.value;

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'ortuId': ortuId,
        'search': searchQuery.value,
      };

      final uri = Uri.parse(
        ApiUrl.santri,
      ).replace(queryParameters: queryParams);

      final response = await get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newItems = List<s.Santri>.from(
          data['data'].map((x) => s.Santri.fromJson(x)),
        );

        if (newItems.length < _perPage) {
          hasMore.value = false;
        }

        childrenList.addAll(newItems);
      } else {
        currentPage--;
        ToastUtils.showErrorToast('Gagal memuat data tambahan');
      }
    } catch (e) {
      currentPage--;
      ToastUtils.showErrorToast('Terjadi kesalahan memuat data tambahan');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void logout() async {
    try {
      isLoadingLogout.value = true;
      final userId = AuthService.to.userId.value;
      final response = await http
          .post(
            Uri.parse(ApiUrl.logout(userId)),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        await AuthService.to.logout();
        Get.offAllNamed('/login');
        ToastUtils.showSuccessToast('Logout berhasil');
      } else {
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Logout gagal');
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
      isLoadingLogout.value = false;
    }
  }
}
