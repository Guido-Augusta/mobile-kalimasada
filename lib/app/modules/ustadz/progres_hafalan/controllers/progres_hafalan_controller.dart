import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/progres_hafalan_juz.dart'
    as juz_model;
import 'package:mobile_kalimasada/app/data/models/progres_hafalan_surah.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgresHafalanController extends GetxController {
  var userRole = ''.obs;
  var isLoading = false.obs;

  late String santriId;
  var santriData = Rxn<Santri>();
  var progresHafalan = <Datum>[].obs;
  var filteredSurahList = <Datum>[].obs;

  var progresHafalanJuz = <juz_model.Datum>[].obs;
  var filteredJuzList = <juz_model.Datum>[].obs;

  // 'surah' or 'juz'
  var filterMode = 'surah'.obs;

  var searchController = TextEditingController();
  var searchQuery = ''.obs;

  RxBool isFabVisible = true.obs;

  final scrollC = ScrollController();

  DateTime? _lastErrorShown;

  @override
  Future<void> onInit() async {
    super.onInit();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userRole.value = prefs.getString('role') ?? '';
    santriId = Get.arguments['santriId'];
    getProgresHafalan(santriId);
    getProgresHafalanJuz(santriId);
  }

  Future<void> getProgresHafalan(String santriId) async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.progresHafalanSurah(santriId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        santriData.value = Santri.fromJson(data['santri']);
        progresHafalan.value = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat');
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
      Future.delayed(const Duration(milliseconds: 300), () {
        isLoading.value = false;
      });
    }
  }

  Future<void> getProgresHafalanJuz(String santriId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.progresHafalanJuz(santriId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        progresHafalanJuz.value = List<juz_model.Datum>.from(
          data['data'].map((x) => juz_model.Datum.fromJson(x)),
        );
      } else {
        ToastUtils.showErrorToast('Gagal memuat data juz');
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
      filteredSurahList.value = List<Datum>.from(progresHafalan);
      return;
    }

    final filteredList = progresHafalan.where((element) {
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
      return juz == query.trim();
    }).toList();

    filteredJuzList.value = filteredList;
  }

  String getLabelTahapan(String tahapan) {
    switch (tahapan) {
      case 'Level1':
        return 'Level 1 - Juz 30';
      case 'Level2':
        return 'Level 2 - Surah Pilihan';
      case 'Level3':
        return 'Level 3 - Juz 1-29';
      default:
        return '-';
    }
  }
}
