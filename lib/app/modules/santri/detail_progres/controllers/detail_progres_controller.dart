// detail_progres_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan.dart';
import 'package:mobile_kalimasada/app/data/models/detail_surah.dart' hide Ayat;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

class DetailProgresController extends GetxController {
  RxBool isFabVisible = true.obs;

  RxBool isSurahInfoLoading = false.obs;
  RxBool isDetailProgresLoading = false.obs;
  final santriId = Get.arguments['santriId'].toString();
  final surahId = Get.arguments['surahId'].toString();
  var detailProgres = Rxn<DetailHafalan>();
  var surahInfo = Rxn<DetailSurah>();

  AudioPlayer audioPlayer = AudioPlayer();

  final listC = ListController();
  final scrollC = ScrollController();
  RxInt lastCheckedAyat = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getSurahInfo();
  }

  @override
  void onClose() {
    super.onClose();
    audioPlayer.dispose();
  }

  void getLastCheckedIndex(List<Ayat> ayat) {
    for (int i = 0; i < ayat.length; i++) {
      if (ayat[i].checked == true) {
        lastCheckedAyat.value = i;
      }
    }
  }

  void getDetailProgres() async {
    try {
      isDetailProgresLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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
        getLastCheckedIndex(detailProgres.value!.ayat);
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isDetailProgresLoading.value = false;
    }
  }

  void getSurahInfo() async {
    try {
      isSurahInfoLoading.value = true;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/alquran/surah/$surahId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        getDetailProgres();

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
        ToastUtils.showErrorToast('Gagal memuat surah');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isSurahInfoLoading.value = false;
    }
  }
}
