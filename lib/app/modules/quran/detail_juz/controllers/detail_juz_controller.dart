import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/detail_juz.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../../../../services/auth_service.dart';

class DetailJuzController extends GetxController {
  RxBool isLoading = false.obs;
  final juzId = Get.arguments.toString();
  var detailJuz = Rxn<DetailJuz>();

  RxBool isFabVisible = true.obs;

  final listC = ListController();
  final scrollC = ScrollController();

  @override
  void onInit() {
    super.onInit();
    getDetailJuz();
  }

  void getDetailJuz() async {
    try {
      isLoading.value = true;
      final token = AuthService.to.token;

      final response = await http
          .get(
            Uri.parse(ApiUrl.juzDetail(juzId)),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        detailJuz.value = DetailJuz.fromJson(data);
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
