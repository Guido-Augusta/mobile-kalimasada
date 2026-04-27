import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart' as o;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

class OrtuHomeController extends GetxController {
  var isLoading = true.obs;
  var isLoadingChildren = true.obs;
  var isLoadingLogout = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var ortu = Rxn<o.Ortu>();
  var childrenList = RxList<s.Santri>();

  var currentIndex = 0.obs;

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getOrtu();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getOrtu() async {
    try {
      isLoading.value = true;
      final token = AuthService.to.token.value;
      final ortuId = AuthService.to.roleId.value;

      final response = await get(
        Uri.parse(ApiUrl.ortuDetail(ortuId)),
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
        ortu.value = o.Ortu.fromJson(data['data']);
        if (ortu.value?.fotoProfil?.isNotEmpty == true) {
          fotoProfil.value = getImageUrl(ortu.value!.fotoProfil!);
        }

        if (ortu.value?.santri != null && ortu.value!.santri.isNotEmpty) {
          isLoadingChildren.value = true;
          await getChildrenList();
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
      isLoadingChildren.value = false;
    }
  }

  Future<void> getChildrenList() async {
    try {
      if (ortu.value?.santri == null || ortu.value!.santri.isEmpty) {
        childrenList.clear();
        return;
      }

      // Map to futures and preserve order
      final futures = ortu.value!.santri
          .map((santri) => getChildren(santri.id.toString()))
          .toList();

      // Wait for all results
      final results = await Future.wait(futures, eagerError: false);

      // Filter out null results (failed requests) and update list in one go
      final List<s.Santri> validChildren = results
          .whereType<s.Santri>()
          .toList();

      childrenList.assignAll(validChildren);
    } catch (e) {
      ToastUtils.showErrorToast('Gagal memuat data anak');
    }
  }

  Future<s.Santri?> getChildren(String santriId) async {
    try {
      final token = AuthService.to.token.value;
      final response = await get(
        Uri.parse(ApiUrl.santriDetail(santriId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      ).timeout(const Duration(seconds: 30));

      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return s.Santri.fromJson(data['data']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
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
