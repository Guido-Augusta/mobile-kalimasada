import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/detail_riwayat_hafalan.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailRiwayatHafalanController extends GetxController {
  final isLoading = false.obs;
  final santriId = Get.arguments['santriId'];
  final surahId = Get.arguments['surahId'];
  final tanggalRiwayat = Get.arguments['tanggalRiwayat'];
  final status = Get.arguments['status'];

  var detailRiwayatHafalan = Rxn<DetailRiwayatHafalan>();

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

      // Konversi semua arguments ke string untuk memastikan tipe data yang benar
      final santriIdStr = santriId?.toString() ?? '';
      final surahIdStr = surahId?.toString() ?? '';
      final tanggalRiwayatStr = tanggalRiwayat?.toString().split(' ')[0] ?? '';
      final statusStr = status?.toString() ?? '';

      if (santriIdStr.isEmpty ||
          surahIdStr.isEmpty ||
          tanggalRiwayatStr.isEmpty ||
          statusStr.isEmpty) {
        ToastUtils.showErrorToast('Data tidak lengkap');
        isLoading.value = false;
        return;
      }

      final queryParams = {'tanggal': tanggalRiwayatStr, 'status': statusStr};

      final uri = Uri.parse(
        ApiUrl.detailRiwayatHafalan(santriIdStr, surahIdStr),
      ).replace(queryParameters: queryParams);

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
        final riwayat = DetailRiwayatHafalan.fromJson(data);
        detailRiwayatHafalan.value = riwayat;
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
