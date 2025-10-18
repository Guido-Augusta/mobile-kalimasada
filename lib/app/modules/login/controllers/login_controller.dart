import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables for UI state
  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    super.onClose();
    emailController.clear();
    passwordController.clear();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Handle login process
  void callLoginApi() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      try {
        final response = await post(
          Uri.parse('http://10.0.2.2:5000/api/auth/login'),
          body: jsonEncode({
            'email': emailController.text,
            'password': passwordController.text,
            'platform': 'mobile',
          }),
          headers: {'Content-Type': 'application/json'},
        );

        var data = jsonDecode(response.body);
        print(response.statusCode);
        print(data);

        if (response.statusCode == 200) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', data['token'].toString());
          await prefs.setString('role', data['user']['role'].toString());
          await prefs.setString('userId', data['user']['id'].toString());
          await prefs.setString('roleId', data['user']['roleId'].toString());
          Get.snackbar('Success', 'Login berhasil');
          // Navigate to home or another page
          if (data['user']['role'] == 'santri') {
            Get.offAllNamed('/santri-main');
          } else if (data['user']['role'] == 'ustadz') {
            Get.offAllNamed('/ustadz-main');
          } else if (data['user']['role'] == 'ortu') {
            Get.offAllNamed('/ortu-main');
          } else {
            Get.offAllNamed('/home');
          }
        } else {
          Get.snackbar('Error', data['message'] ?? 'Login gagal');
        }
      } catch (e) {
        Get.snackbar('Error', 'An error occurred: $e');
      }
    } else {
      Get.snackbar('Error', 'Email and password tidak boleh kosong');
    }
  }
}
