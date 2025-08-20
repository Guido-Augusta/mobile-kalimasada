import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final userId = ''.obs;
  final role = ''.obs;
  final token = ''.obs;

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

  void getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';
    final token = prefs.getString('token') ?? '';
    final role = prefs.getString('role') ?? '';
    this.token.value = token;
    this.role.value = role;
    this.userId.value = userId;
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      final response = await post(
        Uri.parse(
          'http://10.0.2.2:5000/api/auth/logout/${prefs.getString('userId')}',
        ),
        headers: {'Content-Type': 'application/json'},
      );
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print(data);
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
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
