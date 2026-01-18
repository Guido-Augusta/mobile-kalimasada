import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/detail_surah.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
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
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.surahDetail(surahId)),
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
        ToastUtils.showErrorToast('Gagal memuat data');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
