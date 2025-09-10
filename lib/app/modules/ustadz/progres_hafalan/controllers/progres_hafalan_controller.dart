import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/progres_hafalan.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgresHafalanController extends GetxController {
  var isLoading = false.obs;
  late String santriId;
  var progresHafalan = Rxn<ProgresHafalan>();

  @override
  void onInit() {
    super.onInit();
    santriId = Get.arguments['santriId'];
    getProgresHafalan(santriId);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
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
        progresHafalan.value = ProgresHafalan.fromJson(data);
      } else {
        Get.snackbar('Error', 'Failed to load ayat');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat memuat ayat');
    } finally {
      isLoading.value = false;
    }
  }

  String convertTahapan(String tahapan) {
    switch (tahapan) {
      case 'Tahap1_Juz30':
        return 'Tahap 1 (Juz 30)';
      case 'Tahap2_SuratPilihan':
        return 'Tahap 2 (Surat Pilihan)';
      case 'Tahap3_Juz1_29':
        return 'Tahap 3 (Juz 1-29)';
      default:
        return 'Belum ada tahapan';
    }
  }
}
