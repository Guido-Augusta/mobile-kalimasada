import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/surah.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DaftarSurahController extends GetxController {
  //TODO: Implement DaftarSurahController
  var surahList = <Surah>[].obs;
  var isLoadingSurah = false.obs;
  var lastReadSurah = Rxn<Surah>();

  @override
  void onInit() {
    super.onInit();
    fetchSurahList();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void fetchSurahList() async {
    try {
      isLoadingSurah.value = true;
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/alquran/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> surahsData = data['data'];
        surahList.value = surahsData
            .map((json) => Surah.fromJson(json))
            .toList();
      } else {
        Get.snackbar('Error', 'Failed to load surahs');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while loading surahs');
    } finally {
      isLoadingSurah.value = false;
    }
  }

  void getLastReadSurah() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final lastReadSurahId = prefs.getString('lastReadSurahId');
    if (lastReadSurahId != null) {
      final surah = surahList.firstWhere(
        (s) => s.id == int.parse(lastReadSurahId),
      );
      lastReadSurah.value = surah;
    }
  }
}
