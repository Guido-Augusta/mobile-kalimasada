import 'dart:convert';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/constants/api_url.dart';
import '../../../../data/models/daftar_ortu.dart';
import '../../../ustadz/daftar_santri/controllers/daftar_santri_controller.dart';

class TambahSantriController extends GetxController {
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final queryParams = {
        'page': '1',
        'limit': '200',
        'tipe': tipe,
        'search': query,
      };

      final uri = Uri.parse(ApiUrl.ortu).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final daftarOrtu = DaftarOrtu.fromJson(data);
        return daftarOrtu.data;
      } else {
        ToastUtils.showErrorToast('Gagal mencari orang tua');
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching ortu: $e');
      }
      final now = DateTime.now();
      if (lastErrorShown == null ||
          now.difference(lastErrorShown!) > const Duration(seconds: 3)) {
        lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
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

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final requestBody = {
        'nama': namaC.text,
        'password': passwordC.text,
        'tahapHafalan': tahapHafalanC.text,
        'ortuId': listIdOrtu,
      };

      final response = await http
          .post(
            Uri.parse(ApiUrl.santri),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      final responseBody = response.body;

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (kDebugMode) {
          print(data);
        }
        if (Get.isRegistered<DaftarSantriController>()) {
          await Get.find<DaftarSantriController>().fetchData();
        }
        resetForm();
        ToastUtils.showSuccessToast('Santri berhasil ditambahkan');
      } else if (response.statusCode == 400) {
        final parsed = jsonDecode(responseBody);
        final message = parsed['message'] ?? 'Data tidak valid';
        ToastUtils.showErrorToast(message);
      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(responseBody);
        }
        ToastUtils.showErrorToast('Gagal menambahkan data santri');
      }
    } catch (e) {
      final now = DateTime.now();
      if (lastErrorShown == null ||
          now.difference(lastErrorShown!) > const Duration(seconds: 3)) {
        lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
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
