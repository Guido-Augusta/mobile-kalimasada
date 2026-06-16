import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/repositories/auth_repository.dart';

enum ForgotPasswordStep { inputEmail, tokenVerification, newPassword }

class ForgotPasswordController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isValidating = false.obs;

  var step = ForgotPasswordStep.inputEmail.obs;

  var tokenVar = ''.obs;

  var emailC = TextEditingController();
  var tokenC = TextEditingController();
  var newPasswordC = TextEditingController();

  var isNewPasswordHidden = true.obs;

  final RxInt countdown = 300.obs; // 5 minutes in seconds
  Timer? _timer;

  var isButtonEnabled = true.obs;

  @override
  void onClose() {
    _timer?.cancel();
    emailC.dispose();
    tokenC.dispose();
    newPasswordC.dispose();
    super.onClose();
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordHidden.value = !isNewPasswordHidden.value;
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

  void startCountdown() {
    countdown.value = 300; // Reset to 5 minutes
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        isButtonEnabled.value = false;
        timer.cancel();
      }
    });
  }

  String get formattedCountdown {
    final minutes = (countdown.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (countdown.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void sendToken() async {
    try {
      isValidating.value = true;

      await _authRepository.forgotPassword(emailC.text);

      step.value = ForgotPasswordStep.tokenVerification;
      formKey.currentState!.reset();
      startCountdown();
      ToastUtils.showSuccessToast(
        'Token berhasil dikirim',
        alignment: Alignment.topCenter,
      );
    } catch (e) {
      ToastUtils.showErrorToast(e.toString(), alignment: Alignment.topCenter);
    } finally {
      isValidating.value = false;
    }
  }

  void tokenVerification() async {
    try {
      isValidating.value = true;

      await _authRepository.verifyToken(tokenC.text);

      tokenVar.value = tokenC.text;
      step.value = ForgotPasswordStep.newPassword;
      formKey.currentState!.reset();
      ToastUtils.showSuccessToast(
        'Token berhasil diverifikasi',
        alignment: Alignment.topCenter,
      );
    } catch (e) {
      ToastUtils.showErrorToast(e.toString(), alignment: Alignment.topCenter);
    } finally {
      isValidating.value = false;
    }
  }

  void changePassword() async {
    try {
      isValidating.value = true;

      await _authRepository.resetPassword(tokenVar.value, newPasswordC.text);

      ToastUtils.showSuccessToast(
        'Password berhasil diubah',
        alignment: Alignment.topCenter,
      );
      showSuccessDialog();
    } catch (e) {
      ToastUtils.showErrorToast(e.toString(), alignment: Alignment.topCenter);
    } finally {
      isValidating.value = false;
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
