import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:mobile_kalimasada/app/data/models/detail_surah.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailSurahController extends GetxController {
  RxBool isLoading = false.obs;
  final surahId = Get.arguments.toString();
  var detailSurah = Rxn<DetailSurah>();

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    getDetailSurah();
  }

  @override
  void onClose() {
    super.onClose();
    audioPlayer.dispose();
  }

  void getDetailSurah() async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'No authentication token found');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/alquran/surah/$surahId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        detailSurah.value = DetailSurah.fromJson(data);

        // Set audio source when surah info is loaded
        if (detailSurah.value?.audio != null &&
            detailSurah.value!.audio!.isNotEmpty) {
          String audioUrl = detailSurah.value!.audio!
              .replaceAll('localhost', '10.0.2.2')
              .replaceAll('127.0.0.1', '10.0.2.2');

          audioPlayer.setUrl(audioUrl);
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch detail surah');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch detail surah');
    } finally {
      isLoading.value = false;
    }
  }
}
