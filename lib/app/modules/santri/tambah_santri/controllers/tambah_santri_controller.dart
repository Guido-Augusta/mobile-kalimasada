import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_ortu.dart';
import 'package:mobile_kalimasada/app/data/repositories/ortu_repository.dart';
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../admin/admin_home/controllers/admin_home_controller.dart';
import '../../daftar_santri/controllers/daftar_santri_controller.dart';

class TambahSantriController extends GetxController {
  final SantriRepository _santriRepository = SantriRepository();
  final OrtuRepository _ortuRepository = OrtuRepository();

  final RxBool isSearching = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> ortuFormKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> passwordFieldKey = GlobalKey<FormFieldState>();
  var ayahDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
  var ibuDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
  var waliDropdownKey = GlobalKey<DropdownSearchState<Datum>>();

  var namaC = TextEditingController();
  var tahapHafalanC = TextEditingController(text: 'Level1');
  var passwordC = TextEditingController();

  var selectedAyah = Rxn<Datum>();
  var selectedIbu = Rxn<Datum>();
  var selectedWali = Rxn<Datum>();

  DateTime? lastErrorShown;

  @override
  void onClose() {
    namaC.dispose();
    tahapHafalanC.dispose();
    passwordC.dispose();
    super.onClose();
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

  Future<void> addSantri() async {
    try {
      isSaveProfileLoading.value = true;

      List<int> listIdOrtu = [];
      if (selectedAyah.value != null) {
        listIdOrtu.add(selectedAyah.value!.id!);
      }
      if (selectedIbu.value != null) {
        listIdOrtu.add(selectedIbu.value!.id!);
      }
      if (selectedWali.value != null) {
        listIdOrtu.add(selectedWali.value!.id!);
      }

      if (kDebugMode) {
        print(listIdOrtu);
      }

      await _santriRepository.addSantri(
        nama: namaC.text,
        password: passwordC.text,
        tahapHafalan: tahapHafalanC.text,
        ortuId: listIdOrtu,
      );

      if (Get.isRegistered<DaftarSantriController>()) {
        await Get.find<DaftarSantriController>().getSantriList();
      }
      if (Get.isRegistered<AdminHomeController>()) {
        await Get.find<AdminHomeController>().fetchTotals();
      }
      resetForm();
      ToastUtils.showSuccessToast('Santri berhasil ditambahkan');
    } on AppException catch (e) {
      if (kDebugMode) {
        print('Error adding santri: ${e.message}');
      }
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding santri: $e');
      }
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isSaveProfileLoading.value = false;
    }
  }

  void resetForm() {
    passwordC.clear();
    namaC.clear();
    tahapHafalanC.text = 'Level1';

    selectedAyah.value = null;
    selectedIbu.value = null;
    selectedWali.value = null;

    ortuFormKey = GlobalKey<FormState>();
    profileFormKey = GlobalKey<FormState>();
    passwordFieldKey = GlobalKey<FormFieldState>();
    ayahDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
    ibuDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
    waliDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
    update();
  }
}
