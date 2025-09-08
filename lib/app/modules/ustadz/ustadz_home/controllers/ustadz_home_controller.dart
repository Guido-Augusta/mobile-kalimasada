import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UstadzHomeController extends GetxController {
  //TODO: Implement UstadzHomeController

  var userId = ''.obs;
  var roleId = ''.obs;
  var role = ''.obs;
  var token = ''.obs;
  var name = ''.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  void getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId.value = prefs.getString('userId') ?? '';
    roleId.value = prefs.getString('roleId') ?? '';
    token.value = prefs.getString('token') ?? '';
    role.value = prefs.getString('role') ?? '';
    name.value = prefs.getString('name') ?? '';

    try {
      final response = await get(
        Uri.parse('http://10.0.2.2:5000/api/ustadz/${roleId.value}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${token.value}',
          'x-platform': 'mobile',
        },
      );
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print(data);
      if (response.statusCode == 200) {
        name.value = data['data']['nama'];
        fotoProfil.value = getImageUrl(data['data']['fotoProfil']);
      } else {
        Get.snackbar('Error', data['message'] ?? 'Gagal mendapatkan data');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await post(
        Uri.parse('http://10.0.2.2:5000/api/auth/logout/${userId.value}'),
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
        await prefs.remove('name');
        Get.snackbar('Success', 'Logout berhasil');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Logout gagal');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
    Get.offAllNamed('/login');
  }
}
