import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/ustadz.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

class UstadzHomeController extends GetxController {
  var isLoading = true.obs;
  var isLoadingLogout = false.obs;
  var ustadz = Rxn<Ustadz>();
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getUstadz();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getUstadz() async {
    try {
      isLoading.value = true;
      final token = AuthService.to.token.value;
      final ustadzId = AuthService.to.roleId.value;

      final response = await get(
        Uri.parse(ApiUrl.ustadzDetail(ustadzId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      ).timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(response.statusCode);
        print(data);
      }
      if (response.statusCode == 200) {
        ustadz.value = Ustadz.fromJson(data['data']);
        if (ustadz.value?.fotoProfil?.isNotEmpty == true) {
          fotoProfil.value = getImageUrl(ustadz.value!.fotoProfil!);
        }
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data');
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

  void logout() async {
    isLoadingLogout.value = true;
    final userId = AuthService.to.userId.value;
    try {
      final response = await post(
        Uri.parse(ApiUrl.logout(userId)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(response.statusCode);
        print(data);
      }
      if (response.statusCode == 200) {
        await AuthService.to.logout();
        Get.offAllNamed('/login');
        ToastUtils.showSuccessToast('Logout berhasil');
      } else {
        final now = DateTime.now();
        if (_lastErrorShown == null ||
            now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
          _lastErrorShown = now;
          ToastUtils.showErrorToast('Logout gagal');
        }
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
      isLoadingLogout.value = false;
    }
  }
}
