import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

import '../../../../data/repositories/auth_repository.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  @override
  void onClose() {
    super.onClose();
    identifierController.clear();
    passwordController.clear();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void callLoginApi() async {
    try {
      isLoading.value = true;

      final data = await _authRepository.login(
        identifierController.text,
        passwordController.text,
      );

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
        Get.offAllNamed('/admin-main');
        ToastUtils.showSuccessToast('Login berhasil');
      } else {
        ToastUtils.showErrorToast('Role tidak ditemukan');
      }
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String? validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email atau Nama tidak boleh kosong';
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
