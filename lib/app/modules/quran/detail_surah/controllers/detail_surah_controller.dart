import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/detail_surah.dart';
import 'package:mobile_kalimasada/app/data/repositories/quran_repository.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../../../utils/audio_helper.dart';

class DetailSurahController extends GetxController {
  final QuranRepository _quranRepository = Get.find();

  RxBool isLoading = false.obs;
  final surahId = Get.arguments.toString();
  var detailSurah = Rxn<DetailSurah>();

  AudioPlayer audioPlayer = AudioPlayer();

  RxBool isFabVisible = true.obs;

  final listC = ListController();
  final scrollC = ScrollController();
  final searchC = TextEditingController();
  RxInt lastCheckedAyat = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getDetailSurah();
  }

  @override
  void onClose() {
    searchC.dispose();
    scrollC.dispose();
    listC.dispose();
    audioPlayer.dispose();
    super.onClose();
  }

  Future<void> getDetailSurah() async {
    try {
      isLoading.value = true;
      detailSurah.value = await _quranRepository.fetchSurahDetail(surahId);

      // Set audio source when surah info is loaded
      if (detailSurah.value?.audio != null &&
          detailSurah.value!.audio!.isNotEmpty) {
        final String audioUrl = AudioHelper.getAudioUrl(
          detailSurah.value!.audio!,
        );

        try {
          final mediaItem = MediaItem(
            id: detailSurah.value?.nomor?.toString() ?? surahId,
            title: detailSurah.value?.namaLatin ?? 'Surah $surahId',
            album: 'Al-Quran',
          );

          await audioPlayer.setAudioSource(
            AudioSource.uri(Uri.parse(audioUrl), tag: mediaItem),
          );
          if (kDebugMode) {
            print('Audio loaded successfully');
          }
        } catch (e) {
          if (kDebugMode) {
            print('Audio loading error: $e');
          }
          ToastUtils.showErrorToast('Gagal memuat audio');
        }
      }
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  void scrollToAyat(int nomor) {
    final ayatList = detailSurah.value?.ayat ?? [];
    final targetIndex = ayatList.indexWhere((a) => a.nomor == nomor);

    if (targetIndex != -1) {
      if (listC.isAttached) {
        listC.animateToItem(
          index: targetIndex,
          scrollController: scrollC,
          alignment: 0,
          duration: (estimatedDistance) => const Duration(milliseconds: 800),
          curve: (estimatedDistance) => Curves.easeInOutCubic,
        );
      }
    } else {
      ToastUtils.showErrorToast('Ayat $nomor tidak ditemukan');
    }
  }
}
