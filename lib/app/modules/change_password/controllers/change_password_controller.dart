import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChangePasswordStep { oldPassword, newPassword }

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isValidating = false.obs;

  var step = ChangePasswordStep.oldPassword.obs;

  var oldPasswordVar = ''.obs;
  var newPasswordVar = ''.obs;

  final oldPasswordC = TextEditingController();
  final newPasswordC = TextEditingController();
  var isOldPasswordHidden = true.obs;
  var isNewPasswordHidden = true.obs;

  void toggleOldPasswordVisibility() {
    isOldPasswordHidden.value = !isOldPasswordHidden.value;
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
  }

  void changePasswordStep1(String oldPassword) async {
    try {
      isValidating.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast(
          'Token tidak ditemukan\nSilakan login kembali',
        );
      }

      final response = await http.post(
        Uri.parse(ApiUrl.verifyOldPassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({'oldPassword': oldPassword}),
      );

      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        step.value = ChangePasswordStep.newPassword;
        oldPasswordVar.value = oldPassword;
        formKey.currentState!.reset();
        ToastUtils.showSuccessToast('Password lama berhasil diverifikasi');
      } else {
        ToastUtils.showErrorToast('Verifikasi gagal');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isValidating.value = false;
    }
  }

  void changePasswordStep2(String newPassword) async {
    try {
      isValidating.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast(
          'Token tidak ditemukan\nSilakan login kembali',
        );
      }

      final response = await http.post(
        Uri.parse(ApiUrl.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'oldPassword': oldPasswordVar.value,
          'newPassword': newPassword,
        }),
      );

      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        await logout();
        ToastUtils.showSuccessToast('Password berhasil diubah');
        showSuccessDialog();
      } else {
        ToastUtils.showErrorToast('Gagal mengubah password');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    try {
      final response = await http.post(
        Uri.parse(ApiUrl.logout(userId!)),
        headers: {'Content-Type': 'application/json'},
      );
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
      } else {
        ToastUtils.showErrorToast('Gagal logout');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }

  void showSuccessDialog() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Password berhasil diubah',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Password Anda telah berhasil diubah. Silakan login kembali dengan password baru Anda.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.offAllNamed('/login');
                            ToastUtils.showSuccessToast(
                              'Silahkan login kembali',
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B46C1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Login Kembali',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
