import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

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
      isLoading.value = true;
      final response = await post(
        Uri.parse(ApiUrl.login),
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
          'platform': 'mobile',
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(response.statusCode);
        print(data);
      }

      if (response.statusCode == 200) {
        await AuthService.to.login(
          newToken: data['token'].toString(),
          newRole: data['user']['role'].toString(),
          newUserId: data['user']['id'].toString(),
          newRoleId: data['user']['roleId'].toString(),
        );

        // Navigate to home or another page
        if (data['user']['role'] == 'santri') {
          Get.offAllNamed('/santri-main');
          ToastUtils.showSuccessToast('Login berhasil');
        } else if (data['user']['role'] == 'ustadz') {
          Get.offAllNamed('/ustadz-main');
          ToastUtils.showSuccessToast('Login berhasil');
        } else if (data['user']['role'] == 'ortu') {
          Get.offAllNamed('/ortu-main');
          ToastUtils.showSuccessToast('Login berhasil');
        } else if (data['user']['role'] == 'admin') {
          Get.offAllNamed('/admin-home');
          ToastUtils.showSuccessToast('Login berhasil');
        } else {
          ToastUtils.showSuccessToast('Role tidak ditemukan');
        }
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        ToastUtils.showErrorToast('Email atau password salah');
      } else {
        ToastUtils.showErrorToast('Login gagal');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isLoading.value = false;
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

  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password tidak boleh kosong';
    } else if (password.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }
}
