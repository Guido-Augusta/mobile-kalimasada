import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../data/exceptions/app_exception.dart';
import '../../../../data/models/daftar_ortu.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../../../../utils/image_helper.dart';
import '../../../../utils/toast_utils.dart';
import '../../../admin/admin_home/controllers/admin_home_controller.dart';

class DaftarOrtuController extends GetxController {
  final OrtuRepository _ortuRepository = Get.find();

  final isLoading = false.obs;
  final isSaveLoading = false.obs;
  final isLoadingDeleteAccount = false.obs;

  var searchQuery = ''.obs;
  var appliedSearchQuery = ''.obs;
  var searchController = TextEditingController();

  var ortuList = <Datum>[].obs;

  final int _perPage = 15;
  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  final scrollController = ScrollController();
  RxBool isFabVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    setupScrollController();

    debounce(searchQuery, (callback) {
      appliedSearchQuery.value = searchQuery.value;
      fetchData();
    }, time: const Duration(milliseconds: 700));
  }

  @override
  void onClose() {
    scrollController.dispose();
    searchController.dispose();
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

      final result = await _ortuRepository.fetchOrtuList(
        page: currentPage,
        limit: _perPage,
        search: searchQuery.value,
      );

      final items = result.data;

      if (items.length < _perPage) {
        hasMore.value = false;
      }

      ortuList.value = items;
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final result = await _ortuRepository.fetchOrtuList(
        page: currentPage,
        limit: _perPage,
        search: searchQuery.value,
      );

      final newItems = result.data;

      if (newItems.length < _perPage) {
        hasMore.value = false;
      }

      ortuList.addAll(newItems);
    } on AppException catch (e) {
      currentPage--; // Revert page on error
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      currentPage--; // Revert page on error
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> deleteOrtuAccount(String ortuId) async {
    try {
      isLoadingDeleteAccount.value = true;
      await _ortuRepository.deleteOrtu(ortuId);
      await fetchData();
      if (Get.isRegistered<AdminHomeController>()) {
        await Get.find<AdminHomeController>().fetchTotals();
      }
      Get.back();
      ToastUtils.showSuccessToast('Orang tua berhasil dihapus');
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingDeleteAccount.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }
}
