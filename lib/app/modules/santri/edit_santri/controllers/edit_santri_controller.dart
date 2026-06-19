import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_ortu.dart';
import 'package:mobile_kalimasada/app/data/repositories/ortu_repository.dart';
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';
import 'package:mobile_kalimasada/app/modules/santri/daftar_santri/controllers/daftar_santri_controller.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/models/santri.dart';
import '../../../../data/models/santri.dart' as s;
import '../../detail_santri/controllers/detail_santri_controller.dart';

class EditSantriController extends GetxController {
  final String santriId = Get.arguments['santriId'];

  final SantriRepository _santriRepository = SantriRepository();
  final OrtuRepository _ortuRepository = OrtuRepository();

  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSavePasswordLoading = false.obs;

  final RxBool isPasswordVisible = false.obs;

  var santriDetail = Rxn<Santri>();

  final profileFormKey = GlobalKey<FormState>();
  final passwordFormKey = GlobalKey<FormState>();

  var namaC = TextEditingController();
  var tahapHafalanC = TextEditingController(text: 'Level1');
  var passwordC = TextEditingController();

  var selectedAyah = Rxn<Datum>();
  var selectedIbu = Rxn<Datum>();
  var selectedWali = Rxn<Datum>();

  final santriDummy = Santri(
    id: 0,
    userId: 0,
    nama: 'Loading...',
    tahapHafalan: '',
    orangTua: [],
    totalPoin: 0,
    peringkat: 0,
    createdAt: DateTime.now(),
    poinUpdatedAt: DateTime.now(),
    user: null,
    waliKelas: [],
  );

  DateTime? lastErrorShown;
  DateTime? _lastNoChangeShown;

  @override
  void onInit() async {
    super.onInit();
    getSantriDetail();
  }

  @override
  void onClose() {
    namaC.dispose();
    tahapHafalanC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  Future<void> getSantriDetail({bool isReload = true}) async {
    try {
      isLoading.value = isReload;
      final santri = await _santriRepository.getSantri(santriId);
      santriDetail.value = santri;

      // Initialize text controllers with current values
      namaC.text = santriDetail.value!.nama ?? '';
      tahapHafalanC.text = santriDetail.value!.tahapHafalan ?? 'Level1';

      // Set selected items
      selectedAyah.value = convertOrangTuaToDatum(
        getOrangTuaByTipe(santriDetail.value!.orangTua, 'Ayah'),
      );
      selectedIbu.value = convertOrangTuaToDatum(
        getOrangTuaByTipe(santriDetail.value!.orangTua, 'Ibu'),
      );
      selectedWali.value = convertOrangTuaToDatum(
        getOrangTuaByTipe(santriDetail.value!.orangTua, 'Wali'),
      );
      if (kDebugMode) {
        print('Santri detail loaded: ${santri.nama}');
      }
    } on AppException catch (e) {
      if (kDebugMode) {
        print('Error getting santri detail: ${e.message}');
      }
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting santri detail: $e');
      }
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  s.OrangTua? getOrangTuaByTipe(List<s.OrangTua> orangTua, String tipe) {
    if (orangTua.isEmpty) return null;
    try {
      final result = orangTua.where(
        (element) => element.tipe?.toLowerCase() == tipe.toLowerCase(),
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  Datum? getSelectedOrtuByTipe(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'ayah':
        return selectedAyah.value;
      case 'ibu':
        return selectedIbu.value;
      case 'wali':
        return selectedWali.value;
      default:
        return null;
    }
  }

  Datum? convertOrangTuaToDatum(s.OrangTua? orangTua) {
    if (orangTua == null) return null;

    return Datum(
      id: orangTua.id,
      userId: null,
      nama: orangTua.nama,
      nomorHp: null,
      alamat: null,
      jenisKelamin: null,
      fotoProfil: null,
      tipe: orangTua.tipe,
      user: null,
    );
  }

  Future<List<Datum>> loadOrtuByTipe(String tipe, String? query) async {
    try {
      isSearching.value = true;
      final daftarOrtu = await _ortuRepository.fetchOrtuList(
        page: 1,
        limit: 200,
        search: query ?? '',
        tipe: tipe,
      );
      return daftarOrtu.data;
    } on AppException catch (e) {
      if (kDebugMode) {
        print('Error searching ortu: ${e.message}');
      }
      ToastUtils.showErrorToast(e.message);
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error searching ortu: $e');
      }
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
      return [];
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> updateProfileSantri(
    String? nama,
    String? tahapHafalan,
    Datum? selectedAyah,
    Datum? selectedIbu,
    Datum? selectedWali,
  ) async {
    try {
      bool hasNoChange =
          (nama == santriDetail.value?.nama &&
          tahapHafalan == santriDetail.value?.tahapHafalan &&
          selectedAyah?.id ==
              getOrangTuaIdByTipe(santriDetail.value!.orangTua, 'Ayah') &&
          selectedIbu?.id ==
              getOrangTuaIdByTipe(santriDetail.value!.orangTua, 'Ibu') &&
          selectedWali?.id ==
              getOrangTuaIdByTipe(santriDetail.value!.orangTua, 'Wali'));

      if (hasNoChange) {
        final now = DateTime.now();
        if (_lastNoChangeShown == null ||
            now.difference(_lastNoChangeShown!) > Duration(seconds: 3)) {
          _lastNoChangeShown = now;
          ToastUtils.showErrorToast('Tidak ada perubahan data');
        }
        return;
      }
      isSaveProfileLoading.value = true;

      List<int> listIdOrtu = [];
      if (selectedAyah != null) listIdOrtu.add(selectedAyah.id!);
      if (selectedIbu != null) listIdOrtu.add(selectedIbu.id!);
      if (selectedWali != null) listIdOrtu.add(selectedWali.id!);

      await _santriRepository.updateProfile(
        santriId: santriId,
        nama: nama ?? santriDetail.value?.nama ?? '',
        tahapHafalan: tahapHafalan ?? santriDetail.value?.tahapHafalan ?? '',
        ortuId: listIdOrtu,
      );

      await getSantriDetail(isReload: false);
      if (Get.isRegistered<DetailSantriController>()) {
        await Get.find<DetailSantriController>().getSantriDetail(
          santriId,
          isRefresh: false,
        );
      }
      if (Get.isRegistered<DaftarSantriController>()) {
        await Get.find<DaftarSantriController>().getSantriList();
      }
      ToastUtils.showSuccessToast('Profil berhasil diperbarui');
    } on AppException catch (e) {
      if (kDebugMode) {
        print('Error updating profile: ${e.message}');
      }
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isSaveProfileLoading.value = false;
    }
  }

  Future<void> updatePasswordSantri(String? passwordBaru) async {
    try {
      if (passwordBaru == null || passwordBaru.isEmpty) {
        ToastUtils.showErrorToast('Password baru tidak boleh kosong');
        return;
      }

      isSavePasswordLoading.value = true;

      await _santriRepository.updatePassword(
        santriId: santriId,
        password: passwordBaru,
      );

      if (Get.isRegistered<DetailSantriController>()) {
        await Get.find<DetailSantriController>().getSantriDetail(
          santriId,
          isRefresh: false,
        );
      }
      if (Get.isRegistered<DaftarSantriController>()) {
        await Get.find<DaftarSantriController>().getSantriList();
      }
      Get.back();
      Future.delayed(const Duration(seconds: 1), () {
        passwordC.clear();
      });
      ToastUtils.showSuccessToast('Password berhasil diperbarui');
    } on AppException catch (e) {
      if (kDebugMode) {
        print('Error updating password: ${e.message}');
      }
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating password: $e');
      }
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isSavePasswordLoading.value = false;
    }
  }

  int? getOrangTuaIdByTipe(List<s.OrangTua> orangTua, String tipe) {
    if (orangTua.isEmpty) return null;
    try {
      final result = orangTua.where(
        (element) => element.tipe?.toLowerCase() == tipe.toLowerCase(),
      );
      return result.isNotEmpty ? result.first.id : null;
    } catch (e) {
      return null;
    }
  }

  String generatePassword({int length = 8}) {
    const lowerCase = "abcdefghijklmnopqrstuvwxyz";
    const upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbers = "0123456789";
    const allowedChars = lowerCase + upperCase + numbers;

    final random = Random.secure();
    final charCodes = List.generate(length, (index) {
      return allowedChars.codeUnitAt(random.nextInt(allowedChars.length));
    });

    return String.fromCharCodes(charCodes);
  }
}
