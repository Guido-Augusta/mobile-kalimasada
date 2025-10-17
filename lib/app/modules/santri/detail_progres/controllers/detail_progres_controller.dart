// detail_progres_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan.dart';
import 'package:mobile_kalimasada/app/data/models/detail_surah.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailProgresController extends GetxController {
  // Existing variables
  RxBool isLoading = false.obs;
  final santriId = Get.arguments['santriId'].toString();
  final surahId = Get.arguments['surahId'].toString();
  var detailProgres = Rxn<DetailHafalan>();
  var surahInfo = Rxn<DetailSurah>();

  AudioPlayer audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    getSurahInfo();
    getDetailProgres();
  }

  @override
  void onClose() {
    super.onClose();
    audioPlayer.dispose();
  }

  // Rest of your existing methods...
  void getDetailProgres() async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'No authentication token found');
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/$santriId/surah/$surahId?mode=tambah',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        detailProgres.value = DetailHafalan.fromJson(data);
      } else {
        Get.snackbar('Error', 'Failed to fetch detail progres');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to fetch detail progres: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void getSurahInfo() async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      Get.snackbar('Error', 'No authentication token found');
      isLoading.value = false;
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/alquran/surah/$surahId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        surahInfo.value = DetailSurah.fromJson(data);

        // Set audio source when surah info is loaded
        if (surahInfo.value?.audio != null &&
            surahInfo.value!.audio!.isNotEmpty) {
          String audioUrl = surahInfo.value!.audio!
              .replaceAll('localhost', '10.0.2.2')
              .replaceAll('127.0.0.1', '10.0.2.2');

          audioPlayer.setUrl(audioUrl);
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch surah info');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Failed to fetch surah info: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
