// detail_progres_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan_surah.dart';
import 'package:mobile_kalimasada/app/data/models/detail_surah.dart' hide Ayat;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../progres_hafalan/controllers/progres_hafalan_controller.dart';

class DetailHafalanSurahController extends GetxController {
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
  var detailTambah = Rxn<DetailHafalan>();
  var detailMurajaah = Rxn<DetailHafalan>();
  var detailTahsin = Rxn<DetailHafalan>();

  var surahInfo = Rxn<DetailSurah>();

  AudioPlayer audioPlayer = AudioPlayer();

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

  DetailHafalan? get currentDetail {
    if (selectedTab.value == 0) return detailTambah.value;
    if (selectedTab.value == 1) return detailMurajaah.value;
    return detailTahsin.value;
  }

  int get currentLastChecked {
    if (selectedTab.value == 0) return lastCheckedTambah.value;
    if (selectedTab.value == 1) return lastCheckedMurajaah.value;
    return lastCheckedTahsin.value;
  }

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getSurahInfo();
  }

  @override
  void onClose() {
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerSurahTambah(santriId, surahId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        detailTambah.value = DetailHafalan.fromJson(data);
        lastCheckedTambah.value = _getLastCheckedIndex(
          detailTambah.value!.ayat,
        );
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat hafalan');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Periksa koneksi internet Anda');
    } finally {
      isLoadingTambah.value = false;
    }
  }

  Future<void> getDetailMurajaah() async {
    try {
      isLoadingMurajaah.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerSurahMurajaah(santriId, surahId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        detailMurajaah.value = DetailHafalan.fromJson(data);
        lastCheckedMurajaah.value = _getLastCheckedIndex(
          detailMurajaah.value!.ayat,
        );
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat murajaah');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Periksa koneksi internet Anda');
    } finally {
      isLoadingMurajaah.value = false;
    }
  }

  Future<void> getDetailTahsin() async {
    try {
      isLoadingTahsin.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.detailHafalanPerSurahTahsin(santriId, surahId)),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        detailTahsin.value = DetailHafalan.fromJson(data);
        lastCheckedTahsin.value = _getLastCheckedIndex(
          detailTahsin.value!.ayat,
        );
      } else {
        ToastUtils.showErrorToast('Gagal memuat ayat tahsin');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Periksa koneksi internet Anda');
    } finally {
      isLoadingTahsin.value = false;
    }
  }

  void getSurahInfo() async {
    try {
      isSurahInfoLoading.value = true;

      final response = await http
          .get(
            Uri.parse(ApiUrl.surahDetail(surahId)),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        getDetailTambah();

        final data = json.decode(response.body);
        surahInfo.value = DetailSurah.fromJson(data);

        // Set audio source when surah info is loaded
        if (surahInfo.value?.audio != null &&
            surahInfo.value!.audio!.isNotEmpty) {
          String audioUrl = surahInfo.value!.audio!
              .replaceAll('localhost', '10.0.2.2')
              .replaceAll('127.0.0.1', '10.0.2.2');

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
      } else {
        ToastUtils.showErrorToast('Gagal memuat surah');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
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

  Future<bool> saveSetoranByAyat(
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final detail = currentDetail;
      if (detail == null) {
        ToastUtils.showErrorToast('Data ayat belum tersedia');
        return false;
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
        return false;
      }
      String status = selectedTab.value == 0
          ? 'TambahHafalan'
          : selectedTab.value == 1
          ? 'Murajaah'
          : 'Tahsin';

      if (kualitas == 'Sangat Baik') {
        kualitas = 'SangatBaik';
      }

      final response = await http.post(
        Uri.parse(ApiUrl.saveSetoranByAyat),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'surahId': surahId,
          'ayatIds': ayatIds,
          'status': status,
          'kualitas': kualitas ?? 'Baik', // Kurang, Cukup, Baik, SangatBaik
          'keterangan': keterangan, // Lanjut, Mengulang
          'catatan': catatan ?? '',
        }),
      );
      if (response.statusCode == 200) {
        ToastUtils.showSuccessToast('Setoran berhasil disimpan');
        if (selectedTab.value == 0) {
          getDetailTambah();
        } else if (selectedTab.value == 1) {
          getDetailMurajaah();
        } else if (selectedTab.value == 2) {
          getDetailTahsin();
        }
        if (Get.isRegistered<ProgresHafalanController>()) {
          await Future.wait([
            Get.find<ProgresHafalanController>().getProgresHafalanSurah(
              santriId.toString(),
            ),
            Get.find<ProgresHafalanController>().getProgresHafalanJuz(
              santriId.toString(),
            ),
          ]);
        }
        return true;
      } else {
        ToastUtils.showErrorToast('Gagal menyimpan setoran');
        return false;
      }
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
      return false;
    } finally {
      Future.delayed(const Duration(milliseconds: 300), () {
        isSaveLoading.value = false;
      });
    }
  }
}
