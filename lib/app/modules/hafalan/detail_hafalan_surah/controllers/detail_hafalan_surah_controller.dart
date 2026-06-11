import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan_surah.dart';
import 'package:mobile_kalimasada/app/data/models/detail_surah.dart' hide Ayat;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../../../data/repositories/hafalan_repository.dart';
import '../../../../data/repositories/quran_repository.dart';
import '../../../../utils/audio_helper.dart';
import '../../progres_hafalan/controllers/progres_hafalan_controller.dart';

class DetailHafalanSurahController extends GetxController {
  final HafalanRepository _hafalanRepository = Get.find<HafalanRepository>();
  final QuranRepository _quranRepository = Get.find<QuranRepository>();

  RxBool isSurahInfoLoading = false.obs;

  // Loading states per mode
  RxBool isLoadingTambah = false.obs;
  RxBool isLoadingMurajaah = false.obs;
  RxBool isLoadingTahsin = false.obs;

  RxBool isSaveLoading = false.obs;

  final santriId = Get.arguments['santriId'].toString();
  final santriName = Get.arguments['santriName'].toString();
  final surahId = Get.arguments['surahId'].toString();

  // Data per mode
  var detailTambah = Rxn<DetailHafalanSurah>();
  var detailMurajaah = Rxn<DetailHafalanSurah>();
  var detailTahsin = Rxn<DetailHafalanSurah>();

  var surahInfo = Rxn<DetailSurah>();

  AudioPlayer audioPlayer = AudioPlayer();
  final Rxn<PlayerState> playerState = Rxn<PlayerState>();
  final Rx<PositionData> positionData = const PositionData(
    position: Duration.zero,
    bufferedPosition: Duration.zero,
    duration: Duration.zero,
  ).obs;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<PositionData>? _positionDataSub;

  RxBool isFabVisible = true.obs;
  RxBool isActionBarVisible = true.obs;

  final listC = ListController();
  final scrollC = ScrollController();
  final searchC = TextEditingController();

  // Last checked per mode
  RxInt lastCheckedTambah = 0.obs;
  RxInt lastCheckedMurajaah = 0.obs;
  RxInt lastCheckedTahsin = 0.obs;

  // 0 = Hafalan, 1 = Murajaah, 2 = Tahsin
  RxInt selectedTab = 0.obs;

  bool get isCurrentLoading {
    if (selectedTab.value == 0) return isLoadingTambah.value;
    if (selectedTab.value == 1) return isLoadingMurajaah.value;
    return isLoadingTahsin.value;
  }

  DetailHafalanSurah? get currentDetail {
    if (selectedTab.value == 0) return detailTambah.value;
    if (selectedTab.value == 1) return detailMurajaah.value;
    return detailTahsin.value;
  }

  int get currentLastChecked {
    if (selectedTab.value == 0) return lastCheckedTambah.value;
    if (selectedTab.value == 1) return lastCheckedMurajaah.value;
    return lastCheckedTahsin.value;
  }

  @override
  void onInit() {
    super.onInit();
    _initAudioListeners();
    getSurahInfo();
  }

  void _initAudioListeners() {
    _playerStateSub = audioPlayer.playerStateStream.listen((state) {
      playerState.value = state;
    });

    _positionDataSub =
        rx.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          audioPlayer.positionStream,
          audioPlayer.bufferedPositionStream,
          audioPlayer.durationStream,
          (position, bufferedPosition, duration) => PositionData(
            position: position,
            bufferedPosition: bufferedPosition,
            duration: duration ?? Duration.zero,
          ),
        ).listen((data) {
          positionData.value = data;
        });
  }

  // Audio helper actions
  void playAudio() => audioPlayer.play();
  void pauseAudio() => audioPlayer.pause();
  void seekAudio(Duration position) => audioPlayer.seek(position);
  void replayAudio() {
    audioPlayer.seek(Duration.zero);
    audioPlayer.play();
  }

  @override
  void onClose() {
    _playerStateSub?.cancel();
    _positionDataSub?.cancel();
    audioPlayer.dispose();
    scrollC.dispose();
    searchC.dispose();
    listC.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    // reset scroll to top on tab change
    if (scrollC.hasClients) {
      scrollC.jumpTo(0);
    }
    // Lazy load
    if (index == 1 && detailMurajaah.value == null) {
      getDetailMurajaah();
    } else if (index == 2 && detailTahsin.value == null) {
      getDetailTahsin();
    }
    isFabVisible.value = true;
    isActionBarVisible.value = true;
  }

  int _getLastCheckedIndex(List<Ayat> ayat) {
    int lastIdx = 0;
    for (int i = 0; i < ayat.length; i++) {
      if (ayat[i].checked == true) {
        lastIdx = i;
      }
    }
    return lastIdx;
  }

  Future<void> getDetailTambah() async {
    try {
      isLoadingTambah.value = true;

      final data = await _hafalanRepository.fetchDetailHafalanSurah(
        santriId,
        surahId,
      );

      detailTambah.value = data;
      lastCheckedTambah.value = _getLastCheckedIndex(detailTambah.value!.ayat);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingTambah.value = false;
    }
  }

  Future<void> getDetailMurajaah() async {
    try {
      isLoadingMurajaah.value = true;

      final data = await _hafalanRepository.fetchDetailMurajaahSurah(
        santriId,
        surahId,
      );

      detailMurajaah.value = data;
      lastCheckedMurajaah.value = _getLastCheckedIndex(
        detailMurajaah.value!.ayat,
      );
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingMurajaah.value = false;
    }
  }

  Future<void> getDetailTahsin() async {
    try {
      isLoadingTahsin.value = true;

      final data = await _hafalanRepository.fetchDetailTahsinSurah(
        santriId,
        surahId,
      );

      detailTahsin.value = data;
      lastCheckedTahsin.value = _getLastCheckedIndex(detailTahsin.value!.ayat);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingTahsin.value = false;
    }
  }

  void getSurahInfo() async {
    try {
      isSurahInfoLoading.value = true;

      await Future.wait([
        _quranRepository.fetchSurahDetail(surahId).then((data) async {
          surahInfo.value = data;

          // Set audio source when surah info is loaded
          if (surahInfo.value?.audio != null &&
              surahInfo.value!.audio!.isNotEmpty) {
            String audioUrl = AudioHelper.getAudioUrl(surahInfo.value!.audio);

            try {
              final mediaItem = MediaItem(
                id: surahInfo.value?.nomor?.toString() ?? surahId,
                title: surahInfo.value?.namaLatin ?? 'Surah $surahId',
                album: 'Al-Quran - Hafalan',
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
        }),
        _hafalanRepository.fetchDetailHafalanSurah(santriId, surahId).then((
          data,
        ) async {
          detailTambah.value = data;
          lastCheckedTambah.value = _getLastCheckedIndex(
            detailTambah.value!.ayat,
          );
        }),
      ]);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isSurahInfoLoading.value = false;
    }
  }

  Future<void> scrollToAyat(int nomor) async {
    final index =
        currentDetail?.ayat.indexWhere((a) => a.nomorAyat == nomor) ?? -1;
    if (index != -1) {
      if (listC.isAttached) {
        listC.animateToItem(
          index: index,
          scrollController: scrollC,
          alignment: 0,
          duration: (estimatedDistance) => const Duration(milliseconds: 800),
          curve: (estimatedDistance) => Curves.easeInOutCubic,
        );
      }
    } else {
      if (nomor != 0) {
        ToastUtils.showErrorToast('Ayat $nomor tidak ditemukan di surah ini');
      }
    }
  }

  Future<void> saveSetoranByAyat(
    int santriId,
    int surahId,
    int ayatMulai,
    int ayatAkhir,
    String? kualitas,
    String keterangan,
    String? catatan,
  ) async {
    try {
      isSaveLoading.value = true;

      final detail = currentDetail;
      if (detail == null) {
        ToastUtils.showErrorToast('Data ayat belum tersedia');
        return;
      }

      List<int> ayatIds = [];
      for (final a in detail.ayat) {
        if (a.nomorAyat != null &&
            a.nomorAyat! >= ayatMulai &&
            a.nomorAyat! <= ayatAkhir) {
          if (a.id != null) ayatIds.add(a.id!);
        }
      }

      if (ayatIds.isEmpty) {
        ToastUtils.showErrorToast('Ayat ID tidak valid');
        return;
      }
      String status = selectedTab.value == 0
          ? 'TambahHafalan'
          : selectedTab.value == 1
          ? 'Murajaah'
          : 'Tahsin';

      if (kualitas == 'Sangat Baik') {
        kualitas = 'SangatBaik';
      }

      await _hafalanRepository.saveSetoranByAyat(
        santriId,
        surahId,
        ayatIds,
        status,
        kualitas,
        keterangan,
        catatan,
      );
      if (selectedTab.value == 0) {
        getDetailTambah();
      } else if (selectedTab.value == 1) {
        getDetailMurajaah();
      } else if (selectedTab.value == 2) {
        getDetailTahsin();
      }
      if (Get.isRegistered<ProgresHafalanController>()) {
        await Get.find<ProgresHafalanController>().loadData();
      }
      ToastUtils.showSuccessToast('Setoran berhasil disimpan');
      Get.back();
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }
}

class PositionData {
  const PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });

  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}
