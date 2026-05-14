import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/peringkat.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PeringkatController extends GetxController {
  var isLoading = false.obs;
  var peringkat = <Datum>[].obs;

  var selectedTahap = 'level1'.obs;
  var searchQuery = ''.obs;
  final appliedSearchQuery = ''.obs;
  var searchController = TextEditingController();

  final int _perPage = 20;
  var currentPage = 1;
  var hasMore = true;
  var isLoadingMore = false.obs;

  final scrollController = ScrollController();

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getPeringkat();
    _setupScrollController();

    debounce(searchQuery, (callback) {
      appliedSearchQuery.value = searchQuery.value;
      getPeringkat();
    }, time: const Duration(milliseconds: 700));
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMore && !isLoadingMore.value) {
          loadMoreData();
        }
      }
    });
  }

  void _resetPagination() {
    currentPage = 1;
    hasMore = true;
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getPeringkat() async {
    try {
      _resetPagination();

      isLoading.value = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final queryParams = {
        'page': currentPage.toString(),
        'limit': _perPage.toString(),
        'search': searchQuery.value,
        'tahapHafalan': selectedTahap.value,
      };

      final uri = Uri.parse(
        ApiUrl.santriRank,
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
        peringkat.clear();
        final data = jsonDecode(response.body);
        peringkat.value = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (peringkat.length < _perPage) {
          hasMore = false;
        }
      } else {
        ToastUtils.showErrorToast('Gagal memuat data peringkat');
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

  void changeTahapFilter(String value) {
    if (selectedTahap.value.toLowerCase() == value.toLowerCase()) {
      return;
    }
    selectedTahap.value = value;
    peringkat.clear();
    getPeringkat();
  }

  Future<void> loadMoreData() async {
    if (isLoadingMore.value || !hasMore) return;

    isLoadingMore.value = true;
    final originalPage = currentPage;
    currentPage++;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final queryParams = {
          'page': currentPage.toString(),
          'limit': _perPage.toString(),
          'search': searchQuery.value,
          'tahapHafalan': selectedTahap.value,
        };

        final uri = Uri.parse(
          ApiUrl.santriRank,
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
          peringkat.addAll(newItems);

          if (newItems.length < _perPage) {
            hasMore = false;
          }
        } else {
          currentPage = originalPage;
          ToastUtils.showErrorToast('Gagal memuat data tambahan');
        }
      } else {
        ToastUtils.showErrorToast('Gagal memuat data tambahan');
      }
    } catch (e) {
      currentPage = originalPage;
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
}
