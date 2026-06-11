import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/peringkat.dart';
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';
import 'package:mobile_kalimasada/app/utils/image_helper.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

class PeringkatController extends GetxController {
  final _santriRepository = Get.find<SantriRepository>();

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

  @override
  void onClose() {
    searchController.dispose();
    scrollController.dispose();
    super.onClose();
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
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> getPeringkat() async {
    try {
      _resetPagination();

      isLoading.value = true;

      final data = await _santriRepository.getPeringkatList(
        currentPage: currentPage,
        limit: _perPage,
        search: searchQuery.value,
        tahapHafalan: selectedTahap.value,
      );

      peringkat.clear();
      peringkat.assignAll(data);

      if (peringkat.length < _perPage) {
        hasMore = false;
      }
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
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
      final data = await _santriRepository.getPeringkatList(
        currentPage: currentPage,
        limit: _perPage,
        search: searchQuery.value,
        tahapHafalan: selectedTahap.value,
      );

      peringkat.addAll(data);

      if (data.length < _perPage) {
        hasMore = false;
      }
    } catch (e) {
      currentPage = originalPage;
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }
}
