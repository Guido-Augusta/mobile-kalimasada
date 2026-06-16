import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

import '../../../../data/repositories/auth_repository.dart';

enum ChangePasswordStep { oldPassword, newPassword }

class ChangePasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

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
      final token = AuthService.to.token.value;

      if (token.isEmpty) {
        await AuthService.to.logout();
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast(
          'Token tidak ditemukan\nSilakan login kembali',
        );
        return;
      }

      await _authRepository.verifyOldPassword(oldPassword);

      step.value = ChangePasswordStep.newPassword;
      oldPasswordVar.value = oldPassword;
      formKey.currentState!.reset();
      ToastUtils.showSuccessToast('Password lama berhasil diverifikasi');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isValidating.value = false;
    }
  }

  void changePasswordStep2(String newPassword) async {
    try {
      isValidating.value = true;
      final token = AuthService.to.token.value;

      if (token.isEmpty) {
        await AuthService.to.logout();
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast(
          'Token tidak ditemukan\nSilakan login kembali',
        );
        return;
      }

      await _authRepository.changePassword(
        oldPasswordVar.value,
        newPassword,
      );

      await logout();
      ToastUtils.showSuccessToast('Password berhasil diubah');
      showSuccessDialog();
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> logout() async {
    final userId = AuthService.to.userId.value;
    try {
      await _authRepository.logout(userId);
      await AuthService.to.logout();
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
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
