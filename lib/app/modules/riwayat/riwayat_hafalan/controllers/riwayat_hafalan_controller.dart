import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_ayat.dart'
    as model_ayat;
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_halaman.dart'
    as model_halaman;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/repositories/riwayat_repository.dart';

class RiwayatHafalanController extends GetxController {
  final RiwayatRepository _riwayatRepository = Get.find<RiwayatRepository>();

  final int santriId = int.parse(Get.arguments['santriId'].toString());

  var filterStatus = 'TambahHafalan'.obs; // TambahHafalan, Murajaah, Tahsin
  var filterMode = 'ayat'.obs; // ayat, halaman

  var profilSantri = Rxn<model_ayat.Santri>();

  var riwayatAyatData = <model_ayat.Datum>[].obs;
  var riwayatHalamanData = <model_halaman.Datum>[].obs;

  final int _perPage = 15;
  var currentPage = 1;
  var hasMore = true.obs;

  var isLoading = false.obs;
  var isLoadingMore = false.obs;

  static const Duration _kMinSkeletonDuration = Duration(milliseconds: 400);

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() async {
    super.onInit();
    getRiwayatData();
    _setupScrollController();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMoreRiwayat();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> getRiwayatData({bool isSilent = false}) async {
    try {
      if (!isSilent) {
        isLoading.value = true;
        riwayatAyatData.clear();
        riwayatHalamanData.clear();
      }
      currentPage = 1;
      hasMore.value = true;

      await Future.wait([
        _fetchRiwayat(),
        if (!isSilent) Future.delayed(_kMinSkeletonDuration),
      ]);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      if (!isSilent) isLoading.value = false;
    }
  }

  Future<void> _fetchRiwayat() async {
    if (filterMode.value == 'ayat') {
      final riwayat = await _riwayatRepository.getRiwayatAyat(
        santriId: santriId,
        page: currentPage,
        limit: _perPage,
        status: filterStatus.value,
      );
      profilSantri.value = riwayat.santri;
      riwayatAyatData.clear();
      riwayatAyatData.addAll(riwayat.data);
      hasMore.value = riwayat.data.length >= _perPage;
    } else {
      final riwayat = await _riwayatRepository.getRiwayatHalaman(
        santriId: santriId,
        page: currentPage,
        limit: _perPage,
        status: filterStatus.value,
      );
      if (riwayat.santri != null) {
        profilSantri.value = model_ayat.Santri.fromJson(
          riwayat.santri!.toJson(),
        );
      }
      riwayatHalamanData.clear();
      riwayatHalamanData.addAll(riwayat.data);
      hasMore.value = riwayat.data.length >= _perPage;
    }
  }

  Future<void> loadMoreRiwayat() async {
    if (!hasMore.value || isLoadingMore.value || isLoading.value) {
      return;
    }
    try {
      isLoadingMore.value = true;
      currentPage++;

      if (filterMode.value == 'ayat') {
        final riwayat = await _riwayatRepository.getRiwayatAyat(
          santriId: santriId,
          page: currentPage,
          limit: _perPage,
          status: filterStatus.value,
        );
        riwayatAyatData.addAll(riwayat.data);
        hasMore.value = riwayat.data.length >= _perPage;
      } else {
        final riwayat = await _riwayatRepository.getRiwayatHalaman(
          santriId: santriId,
          page: currentPage,
          limit: _perPage,
          status: filterStatus.value,
        );
        riwayatHalamanData.addAll(riwayat.data);
        hasMore.value = riwayat.data.length >= _perPage;
      }
    } catch (e) {
      currentPage--;
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshRiwayatHafalan() async {
    await getRiwayatData(isSilent: true);
  }

  void updateFilterStatus(String status) {
    if (isLoading.value) return;
    if (filterStatus.value.toLowerCase() != status.toLowerCase()) {
      filterStatus.value = status;
      getRiwayatData();
    }
  }

  void updateFilterMode(String mode) {
    if (isLoading.value) return;
    if (filterMode.value.toLowerCase() != mode.toLowerCase()) {
      filterMode.value = mode;
      getRiwayatData();
    }
  }

  void deleteRiwayatHafalan({
    required int santriId,
    required String tanggal,
    required String status,
    int? surahId,
    int? juzId,
  }) async {
    try {
      await _riwayatRepository.deleteRiwayatHafalan(
        santriId: santriId,
        tanggal: tanggal,
        status: status,
        mode: filterMode.value,
        surahId: surahId,
        juzId: juzId,
      );

      ToastUtils.showSuccessToast(
        'Riwayat ${getStatusText(status)} berhasil dihapus',
      );
      refreshRiwayatHafalan();
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    }
  }

  String getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'murajaah':
        return 'Murajaah';
      case 'tambahhafalan':
        return 'Hafalan';
      case 'tahsin':
        return 'Tahsin';
      default:
        return status ?? '-';
    }
  }
}
