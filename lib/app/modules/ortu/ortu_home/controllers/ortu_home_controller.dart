import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart' as o;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrtuHomeController extends GetxController {
  var isLoading = false.obs;
  var isLoadingChildren = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var ortu = Rxn<o.Ortu>();
  var childrenList = RxList<s.Santri>();

  var currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    getOrtu();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  void getOrtu() async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final ortuId = prefs.getString('roleId');

      final response = await get(
        Uri.parse(ApiUrl.ortu(ortuId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print(data);
      if (response.statusCode == 200) {
        ortu.value = o.Ortu.fromJson(data['data']);
        fotoProfil.value = getImageUrl(ortu.value!.fotoProfil!);

        if (ortu.value?.santri != null && ortu.value!.santri.isNotEmpty) {
          await getChildrenList();
        }
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
    isLoading.value = false;
  }

  Future<void> getChildren(String santriId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await get(
        Uri.parse(ApiUrl.santriDetail(santriId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        childrenList.addIf(
          !childrenList.any((child) => child.id.toString() == santriId),
          s.Santri.fromJson(data['data']),
        );
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data anak');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }

  Future<void> getChildrenList() async {
    try {
      isLoadingChildren.value = true;
      childrenList.clear();

      if (ortu.value?.santri != null) {
        for (var santri in ortu.value!.santri) {
          await getChildren(santri.id.toString());
        }
      }
    } catch (e) {
      ToastUtils.showErrorToast('Gagal memuat data anak');
    }
    isLoadingChildren.value = false;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    try {
      final response = await post(
        Uri.parse(ApiUrl.logout(userId!)),
        headers: {'Content-Type': 'application/json'},
      );
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print(data);
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showSuccessToast('Logout berhasil');
      } else {
        ToastUtils.showErrorToast('Logout gagal');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }
}
