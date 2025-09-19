import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/progres_hafalan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgresHafalanController extends GetxController {
  var isLoading = false.obs;
  late String santriId;
  var santriData = Rxn<Santri>();
  var progresHafalan = <Datum>[].obs;
  var searchQuery = ''.obs;
  var filteredSurahList = <Datum>[].obs;
  var searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    santriId = Get.arguments['santriId'];
    getProgresHafalan(santriId);
  }

  void getProgresHafalan(String santriId) async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/hafalan/$santriId/surah'),
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
        Get.snackbar('Error', 'Failed to load ayat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
    } finally {
      isLoading.value = false;
    }
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

  String getLabelTingkatan(String tingkatan) {
    switch (tingkatan) {
      case 'Level1':
        return 'Level 1';
      case 'Level2':
        return 'Level 2';
      case 'Level3':
        return 'Level 3';
      default:
        return '-';
    }
  }

  String getLabelTahapan(String tahapan) {
    switch (tahapan) {
      case 'Level1':
        return 'Juz 30';
      case 'Level2':
        return 'Surah Pilihan';
      case 'Level3':
        return 'Juz 1-29';
      default:
        return '-';
    }
  }
}
