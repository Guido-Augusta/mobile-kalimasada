import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

class LoginController extends GetxController {
  final formKey = GlobalKey<FormState>();

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
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text('Login berhasil', style: TextStyle(color: Colors.white)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.check_circle_outline_rounded, color: Colors.green),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 2000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.success,
          style: ToastificationStyle.simple,
        );
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
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Login gagal', style: TextStyle(color: Colors.white)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 2000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      toastification.show(
        context: Get.context!,
        title: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Terjadi kesalahan saat menambahkan hafalan\nPeriksa koneksi internet Anda',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        icon: Icon(Icons.error, color: Colors.white),
        showIcon: true,
        backgroundColor: Color(0xFF6B6B6B),
        borderSide: BorderSide.none,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(milliseconds: 2000),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    }
  }

  String? validateEmail(String? email) {
    RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (email == null || email.isEmpty) {
      return 'Email tidak boleh kosong';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Masukkan email yang valid';
    }
    return null;
  }
}
