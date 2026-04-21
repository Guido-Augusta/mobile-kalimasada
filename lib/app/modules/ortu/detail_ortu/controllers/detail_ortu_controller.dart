import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/models/daftar_santri.dart';
import '../../../../services/auth_service.dart';

class DetailOrtuController extends GetxController {
  var isLoading = false.obs;
  var isLoadingSantriList = false.obs;
  var isSaveLoading = false.obs;
  var ortuDetail = Rxn<Ortu>();
  var santriList = <Datum>[].obs;

  var ortuId = Get.arguments['ortuId'];

  final imagePicker = ImagePicker();
  var isUploadingImage = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();

  DateTime? _lastErrorShown;

  @override
  void onInit() async {
    super.onInit();
    getOrtuDetail(ortuId!);
    if (AuthService.to.isAdmin) {
      getSantriList(ortuId!);
    }
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getOrtuDetail(String ortuId) async {
    try {
      isLoading.value = true;
      final token = AuthService.to.token;

      final response = await http.get(
        Uri.parse(ApiUrl.ortuDetail(ortuId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ortu = Ortu.fromJson(data['data']);
        ortuDetail.value = ortu;
        if (ortu.fotoProfil != null && ortu.fotoProfil!.isNotEmpty) {
          fotoProfil.value = getImageUrl(ortu.fotoProfil!);
        }
        if (kDebugMode) {
          print('Ortu detail loaded: ${ortu.nama}');
        }
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

  Future<void> getSantriList(String ortuId) async {
    try {
      isLoadingSantriList.value = true;
      final token = AuthService.to.token;

      if (token.isEmpty) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final queryParams = {
        'page': '1',
        'limit': '10',
        'ortuId': ortuId.toString(),
      };

      final uri = Uri.parse(
        ApiUrl.santri,
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
        santriList.clear();
        final data = jsonDecode(response.body);
        final items = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        santriList.value = items;
      } else {
        ToastUtils.showErrorToast('Gagal memuat data');
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
      isLoadingSantriList.value = false;
    }
  }
}
