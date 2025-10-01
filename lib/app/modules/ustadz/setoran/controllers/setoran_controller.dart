import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/detail_hafalan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetoranController extends GetxController {
  var isLoading = false.obs;
  var isSaving = false.obs;
  var selectedMode = 'TambahHafalan'.obs;
  var detailHafalan = Rx<DetailHafalan?>(null);
  var selectedAyat = <int>[].obs;
  var catatanController = TextEditingController().obs;

  late String surahId;
  late String santriId;

  @override
  void onInit() {
    super.onInit();
    surahId = Get.arguments['surahId'].toString();
    santriId = Get.arguments['santriId'].toString();
    loadData();
  }

  void loadData() {
    if (selectedMode.value == 'TambahHafalan') {
      getDetailTambahHafalan();
    } else {
      getDetailMurajaah();
    }
  }

  void changeMode(String mode) {
    selectedMode.value = mode;
    selectedAyat.clear();
    loadData();
  }

  void getDetailTambahHafalan() async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/$santriId/surah/$surahId?mode=tambah',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        detailHafalan.value = DetailHafalan.fromJson(data);
      } else {
        Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
    } finally {
      isLoading.value = false;
    }
  }

  void getDetailMurajaah() async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/$santriId/surah/$surahId?mode=murajaah',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        detailHafalan.value = DetailHafalan.fromJson(data);
      } else {
        Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleAyatSelection(int ayatId, bool isChecked) {
    if (isChecked) {
      selectedAyat.add(ayatId);
    } else {
      selectedAyat.remove(ayatId);
    }
  }

  bool isAyatSelected(Ayat ayat) {
    // Jika ayat sudah dihafal, otomatis tercentang dan disabled
    if (ayat.checked == true) {
      return true;
    }
    // Untuk ayat yang belum dihafal, cek apakah ada di selectedAyat
    return selectedAyat.contains(ayat.id ?? 0);
  }

  bool isAyatDisabled(Ayat ayat) {
    return selectedMode.value == 'TambahHafalan' && ayat.checked == true;
  }

  void saveSetoran() async {
    isSaving.value = true;
    if (selectedAyat.isEmpty) {
      Get.snackbar('Peringatan', 'Pilih minimal satu ayat');
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/hafalan/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'surahId': surahId,
          'ayatIds': selectedAyat,
          'status': selectedMode.value,
          'catatan': catatanController.value.text,
        }),
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        Get.snackbar(
          'Berhasil',
          '${selectedMode.value == 'TambahHafalan' ? 'Tambah Hafalan' : 'Murajaah'} berhasil disimpan',
        );
        if (selectedMode.value == 'TambahHafalan') {
          getDetailTambahHafalan();
        } else {
          selectedAyat.clear();
        }
      } else {
        Get.snackbar('Error', 'Gagal menyimpan setoran');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat menyimpan');
    } finally {
      isSaving.value = false;
    }
  }

  String getCurrentDate() {
    return DateTime.now().toString().split(' ')[0];
  }
}
