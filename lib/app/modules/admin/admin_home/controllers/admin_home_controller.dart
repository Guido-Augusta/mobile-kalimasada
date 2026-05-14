import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_ustadz.dart'
    as ustadz_model;
import 'package:mobile_kalimasada/app/data/models/daftar_ortu.dart'
    as ortu_model;
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart'
    as santri_model;

class AdminHomeController extends GetxController {
  var isLoadingLogout = false.obs;
  var isLoadingStats = false.obs;
  var totalUstadz = 0.obs;
  var totalOrtu = 0.obs;
  var totalSantri = 0.obs;

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    fetchTotals();
  }

  Future<void> fetchTotals() async {
    isLoadingStats.value = true;
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AuthService.to.token.value}',
        'x-platform': 'mobile',
      };

      final responses = await Future.wait([
        get(Uri.parse('${ApiUrl.ustadz}?page=1&limit=1'), headers: headers),
        get(Uri.parse('${ApiUrl.ortu}?page=1&limit=1'), headers: headers),
        get(Uri.parse('${ApiUrl.santri}?page=1&limit=1'), headers: headers),
      ]);

      if (responses[0].statusCode == 200) {
        final parsed = ustadz_model.DaftarUstadz.fromJson(
          jsonDecode(responses[0].body),
        );
        totalUstadz.value = parsed.pagination?.totalData ?? 0;
      }
      if (responses[1].statusCode == 200) {
        final parsed = ortu_model.DaftarOrtu.fromJson(
          jsonDecode(responses[1].body),
        );
        totalOrtu.value = parsed.pagination?.totalData ?? 0;
      }
      if (responses[2].statusCode == 200) {
        final parsed = santri_model.DaftarSantri.fromJson(
          jsonDecode(responses[2].body),
        );
        totalSantri.value = parsed.pagination?.totalData ?? 0;
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching totals: $e');
    } finally {
      isLoadingStats.value = false;
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
