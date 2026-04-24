import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

class AdminHomeController extends GetxController {
  var isLoadingLogout = false.obs;
  DateTime? _lastErrorShown;
  DateTime? lastBackPressTime;

  Future<bool> onWillPop() async {
    final currentTime = DateTime.now();
    if (lastBackPressTime == null ||
        currentTime.difference(lastBackPressTime!) >
            const Duration(seconds: 2)) {
      lastBackPressTime = currentTime;
      ToastUtils.showErrorToast('Tekan sekali lagi untuk keluar');
      return false; // Prevent exit
    }
    return true; // Allow exit
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
