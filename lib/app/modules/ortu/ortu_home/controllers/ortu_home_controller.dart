import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart' as o;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/routes/app_pages.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/data/constants/app_constants.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../../../../utils/image_helper.dart';

class OrtuHomeController extends GetxController {
  final OrtuRepository _ortuRepository = Get.find<OrtuRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  // ── State Variables ────────────────────────────────────────────────────────
  final isLoading = true.obs;
  final isLoadingChildren = true.obs;
  final isLoadingLogout = false.obs;
  final isLoadingMore = false.obs;

  final fotoProfil = AppConstants.defaultProfileImageUrl.obs;

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

  @override
  void onInit() {
    super.onInit();
    loadHomeData(isRefresh: true);
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

  String getImageUrl(String? imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> loadHomeData({bool isRefresh = false}) async {
    try {
      isLoading.value = isRefresh;
      isLoadingChildren.value = isRefresh;

      if (isRefresh) {
        resetPagination();
      }

      final ortuId = AuthService.to.roleId.value;

      await Future.wait([
        _ortuRepository.getOrtuDetail(ortuId).then((data) {
          ortu.value = data;
          if (data.fotoProfil?.isNotEmpty == true) {
            fotoProfil.value = ImageHelper.getImageUrl(data.fotoProfil);
          }
        }),
        _ortuRepository
            .getChildrenList(
              ortuId: ortuId,
              page: currentPage,
              limit: _perPage,
              search: searchQuery.value,
            )
            .then((items) {
              childrenList.clear();
              if (items.length < _perPage) {
                hasMore.value = false;
              }
              childrenList.assignAll(items);
            }),
      ]);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
      isLoadingChildren.value = false;
    }
  }

  Future<void> fetchChildrenData() async {
    try {
      isLoadingChildren.value = true;
      resetPagination();

      final ortuId = AuthService.to.roleId.value;
      final items = await _ortuRepository.getChildrenList(
        ortuId: ortuId,
        page: currentPage,
        limit: _perPage,
        search: searchQuery.value,
      );

      if (items.length < _perPage) {
        hasMore.value = false;
      }
      childrenList.assignAll(items);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingChildren.value = false;
    }
  }

  Future<void> loadMoreChildrenData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final ortuId = AuthService.to.roleId.value;
      final newItems = await _ortuRepository.getChildrenList(
        ortuId: ortuId,
        page: currentPage,
        limit: _perPage,
        search: searchQuery.value,
      );

      if (newItems.length < _perPage) {
        hasMore.value = false;
      }
      childrenList.addAll(newItems);
    } catch (e) {
      currentPage--;
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoadingLogout.value = true;
      final userId = AuthService.to.userId.value;

      await _authRepository.logout(userId);
      await AuthService.to.logout();

      Get.offAllNamed(Routes.LOGIN);
      ToastUtils.showSuccessToast('Logout berhasil');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingLogout.value = false;
    }
  }
}
