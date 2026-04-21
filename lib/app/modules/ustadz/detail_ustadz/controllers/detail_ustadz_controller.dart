import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../../data/constants/api_url.dart';
import '../../../../data/models/ustadz.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/toast_utils.dart';

class DetailUstadzController extends GetxController {
  final ustadzId = Get.arguments['ustadzId'];
  final isLoading = true.obs;
  final isSaveLoading = false.obs;
  final isLoadingLogout = false.obs;
  final isUploadingImage = false.obs;
  var ustadzData = Rxn<Ustadz>();
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController();

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    fetchUstadzData();
  }

  Future<void> fetchUstadzData({bool isRefresh = true}) async {
    try {
      isLoading.value = isRefresh;
      final token = AuthService.to.token;

      final response = await http.get(
        Uri.parse(ApiUrl.ustadzDetail(ustadzId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ustadz = Ustadz.fromJson(data['data']);
        ustadzData.value = ustadz;
        if (ustadz.fotoProfil != null && ustadz.fotoProfil!.isNotEmpty) {
          fotoProfil.value = getImageUrl(ustadz.fotoProfil!);
        }
        namaC.text = ustadz.nama!;
        noHpC.text = ustadz.nomorHp!;
        alamatC.text = ustadz.alamat!;
        jenisKelaminC.text = ustadz.jenisKelamin!;
      } else {
        ToastUtils.showErrorToast('Gagal memuat data profil');
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
    } finally {
      isLoading.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }
}
