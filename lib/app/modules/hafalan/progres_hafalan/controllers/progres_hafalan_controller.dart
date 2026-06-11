import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/progres_hafalan_juz.dart'
    as juz_model;
import 'package:mobile_kalimasada/app/data/models/progres_hafalan_surah.dart';
import 'package:mobile_kalimasada/app/data/repositories/hafalan_repository.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class ProgresHafalanController extends GetxController {
  final HafalanRepository _hafalanRepository = Get.find<HafalanRepository>();

  var currentUserRole = AuthService.to.roleString;
  var isLoading = false.obs;

  late String santriId;
  var santriData = Rxn<Santri>();
  var progresHafalanSurah = <Datum>[].obs;
  var filteredSurahList = <Datum>[].obs;

  var progresHafalanJuz = <juz_model.Datum>[].obs;
  var filteredJuzList = <juz_model.Datum>[].obs;

  // 'surah' or 'juz'
  var filterMode = 'surah'.obs;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  RxBool isFabVisible = true.obs;

  final listSurahC = ListController();
  final listJuzC = ListController();
  final scrollC = ScrollController();

  @override
  Future<void> onInit() async {
    super.onInit();
    santriId = Get.arguments['santriId'];
    loadData();
  }

  @override
  void onClose() {
    scrollC.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        _hafalanRepository.fetchProgresHafalanSurah(santriId: santriId).then((
          data,
        ) {
          santriData.value = data.santri;
          progresHafalanSurah.value = data.data;
        }),
        _hafalanRepository.fetchProgresHafalanJuz(santriId: santriId).then((
          data,
        ) {
          progresHafalanJuz.value = data;
        }),
      ]);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void switchFilterMode(String mode) {
    filterMode.value = mode;
    searchQuery.value = '';
    searchController.clear();
    filteredSurahList.value = [];
    filteredJuzList.value = [];
  }

  void searchSurah(String query) {
    if (query.isEmpty) {
      filteredSurahList.value = List<Datum>.from(progresHafalanSurah);
      return;
    }

    final filteredList = progresHafalanSurah.where((element) {
      final nama = element.nama?.toLowerCase() ?? '';
      final namaLatin = element.namaLatin?.toLowerCase() ?? '';
      final nomor = element.nomor?.toString() ?? '';

      return nama.contains(query.toLowerCase()) ||
          namaLatin.contains(query.toLowerCase()) ||
          nomor.contains(query.toLowerCase());
    }).toList();

    filteredSurahList.value = filteredList;
  }

  void searchJuz(String query) {
    if (query.isEmpty) {
      filteredJuzList.value = List<juz_model.Datum>.from(progresHafalanJuz);
      return;
    }

    final filteredList = progresHafalanJuz.where((element) {
      final juz = element.juz?.toString() ?? '';
      return juz.contains(query.toLowerCase());
    }).toList();

    filteredJuzList.value = filteredList;
  }
}
