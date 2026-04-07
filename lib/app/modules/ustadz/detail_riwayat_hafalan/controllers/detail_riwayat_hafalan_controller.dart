import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/detail_riwayat_ayat.dart';
import 'package:mobile_kalimasada/app/data/models/detail_riwayat_halaman.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailRiwayatHafalanController extends GetxController {
  final isLoading = false.obs;
  
  final santriId = Get.arguments['santriId'];
  final tanggalRiwayat = Get.arguments['tanggalRiwayat'];
  final status = Get.arguments['status'];
  
  final surahId = Get.arguments['surahId'];
  final juzId = Get.arguments['juzId'];

  bool get isAyatMode => surahId != null;

  var detailRiwayatAyat = Rxn<DetailRiwayatAyat>();
  var detailRiwayatHalaman = Rxn<DetailRiwayatHalaman>();

  @override
  void onInit() {
    super.onInit();
    getDetailRiwayatHafalan();
  }

  void getDetailRiwayatHafalan() async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final santriIdStr = santriId?.toString() ?? '';
      final tanggalRiwayatStr = tanggalRiwayat?.toString().split(' ')[0] ?? '';
      final statusStr = status?.toString() ?? '';

      if (santriIdStr.isEmpty ||
          tanggalRiwayatStr.isEmpty ||
          statusStr.isEmpty) {
        ToastUtils.showErrorToast('Data tidak lengkap');
        isLoading.value = false;
        return;
      }

      final queryParams = {'tanggal': tanggalRiwayatStr, 'status': statusStr};
      Uri uri;

      if (isAyatMode) {
        final surahIdStr = surahId?.toString() ?? '';
        uri = Uri.parse(
          ApiUrl.detailRiwayatHafalan(santriIdStr, surahIdStr),
        ).replace(queryParameters: queryParams);
      } else {
        final jIdStr = juzId?.toString() ?? '';
        uri = Uri.parse(
          ApiUrl.detailRiwayatHafalanJuz(santriIdStr, jIdStr),
        ).replace(queryParameters: queryParams);
      }

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
        if (isAyatMode) {
          detailRiwayatAyat.value = DetailRiwayatAyat.fromJson(data);
        } else {
          detailRiwayatHalaman.value = DetailRiwayatHalaman.fromJson(data);
        }
      } else {
        ToastUtils.showErrorToast('Gagal memuat detail riwayat hafalan');
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
