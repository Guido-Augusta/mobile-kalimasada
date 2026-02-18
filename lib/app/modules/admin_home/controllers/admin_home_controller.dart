import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminHomeController extends GetxController {
  var isLoadingLogout = false.obs;
  DateTime? _lastErrorShown;

  void logout() async {
    isLoadingLogout.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    try {
      final response = await post(
        Uri.parse(ApiUrl.logout(userId!)),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(response.statusCode);
        print(data);
      }
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
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
