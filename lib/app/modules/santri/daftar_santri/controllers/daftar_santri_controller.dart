import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart' as ds;
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';
import 'package:mobile_kalimasada/app/utils/image_helper.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../services/auth_service.dart';
import '../../../admin/admin_home/controllers/admin_home_controller.dart';

class DaftarSantriController extends GetxController {
  final _santriRepository = Get.find<SantriRepository>();

  final token = AuthService.to.token.value;

  final isLoading = false.obs;
  final isLoadingDeleteAccount = false.obs;

  var searchQuery = ''.obs;
  final appliedSearchQuery = ''.obs;
  var searchController = TextEditingController();

  var tahapHafalan = 'level1'.obs;

  var santriList = <ds.Datum>[].obs;

  final int _perPage = 15;
  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  final scrollController = ScrollController();
  RxBool isFabVisible = true.obs;

  @override
  void onInit() {
    super.onInit();
    getSantriList();
    setupScrollController();

    debounce(searchQuery, (callback) {
      appliedSearchQuery.value = searchQuery.value;
      getSantriList();
    }, time: const Duration(milliseconds: 700));
  }

  @override
  void onClose() {
    searchController.dispose();
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

  Future<void> getSantriList() async {
    try {
      isLoading.value = true;
      resetPagination();

      final res = await _santriRepository.fetchSantriList(
        page: currentPage,
        limit: _perPage,
        tahapHafalan: tahapHafalan.value,
        search: searchQuery.value,
      );

      santriList.clear();

      if (res.data.length < _perPage) {
        hasMore.value = false;
      }

      santriList.assignAll(res.data);
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
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
    getSantriList();
  }

  void loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final res = await _santriRepository.fetchSantriList(
        page: currentPage,
        limit: _perPage,
        tahapHafalan: tahapHafalan.value,
        search: searchQuery.value,
      );

      if (res.data.length < _perPage) {
        hasMore.value = false;
      }

      santriList.addAll(res.data);
    } on AppException catch (e) {
      currentPage--;
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      currentPage--;
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void deleteSantriAccount(String santriId) async {
    isLoadingDeleteAccount.value = true;
    try {
      await _santriRepository.deleteSantri(santriId);
      getSantriList();
      if (Get.isRegistered<AdminHomeController>()) {
        await Get.find<AdminHomeController>().fetchTotals();
      }
      Get.back();
      ToastUtils.showSuccessToast('Santri berhasil dihapus');
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
