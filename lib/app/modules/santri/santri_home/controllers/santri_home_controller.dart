import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

enum ChartType { hafalanBaru, murajaah }

class SantriHomeController extends GetxController {
  var isLoading = true.obs;
  var isLoadingChart = true.obs;
  var isLoadingLogout = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var santri = Rxn<s.Santri>();
  var chart = Rxn<c.Chart>();
  var range = '1w'.obs;

  var selectedChartType = ChartType.hafalanBaru.obs;

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getSantri();
  }

  void updateRange(String newRange) {
    range.value = newRange;
    getChart();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getSantri() async {
    try {
      isLoading.value = true;
      isLoadingChart.value = true;
      final token = AuthService.to.token.value;
      final santriId = AuthService.to.roleId.value;

      final response = await get(
        Uri.parse(ApiUrl.santriDetail(santriId)),
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
        getChart();
        santri.value = s.Santri.fromJson(data['data']);
        fotoProfil.value = getImageUrl(santri.value!.fotoProfil!);
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
      isLoadingChart.value = false;
    }
  }

  void getChart() async {
    try {
      isLoadingChart.value = true;
      final token = AuthService.to.token.value;
      final santriId = AuthService.to.roleId.value;

      final queryParams = {'range': range.value, 'santriId': santriId};

      final uri = Uri.parse(ApiUrl.chart).replace(queryParameters: queryParams);

      final response = await get(
        uri,
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
        chart.value = c.Chart.fromJson(data);
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data chart');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
    isLoadingChart.value = false;
  }

  void logout() async {
    try {
      isLoadingLogout.value = true;
      final userId = AuthService.to.userId.value;
      final response = await http
          .post(
            Uri.parse(ApiUrl.logout(userId)),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (kDebugMode) {
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
