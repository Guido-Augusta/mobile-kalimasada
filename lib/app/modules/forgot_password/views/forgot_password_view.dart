import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),

                // Logo/Title Section
                Obx(() {
                  return Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.3,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Lupa Password',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        textAlign: TextAlign.center,
                        controller.step.value == ForgotPasswordStep.inputEmail
                            ? 'Masukkan Email Anda'
                            : controller.step.value ==
                                  ForgotPasswordStep.tokenVerification
                            ? 'Masukkan Token yang dikirim ke email Anda'
                            : 'Masukkan Password Baru',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),

                      if (controller.step.value ==
                              ForgotPasswordStep.tokenVerification ||
                          controller.step.value ==
                              ForgotPasswordStep.newPassword)
                        Column(
                          children: [
                            const SizedBox(height: 24),
                            // Time Counter
                            Text(
                              controller.formattedCountdown,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }),

                const SizedBox(height: 24),

                // Login Form
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Password Field
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.step.value ==
                                      ForgotPasswordStep.inputEmail
                                  ? 'Email'
                                  : controller.step.value ==
                                        ForgotPasswordStep.tokenVerification
                                  ? 'Token'
                                  : 'Password Baru',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Email Field
                            if (controller.step.value ==
                                ForgotPasswordStep.inputEmail)
                              TextFormField(
                                controller: controller.emailC,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Email',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[500],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),

                            // Token Verification Field
                            if (controller.step.value ==
                                ForgotPasswordStep.tokenVerification)
                              TextFormField(
                                controller: controller.tokenC,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan 6 Digit Token',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[500],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),

                            // New Password Field
                            if (controller.step.value ==
                                ForgotPasswordStep.newPassword)
                              TextFormField(
                                controller: controller.newPasswordC,
                                keyboardType: TextInputType.visiblePassword,
                                obscureText:
                                    controller.isNewPasswordHidden.value,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan Password Baru',
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[500],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent.withValues(
                                        alpha: 0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.isNewPasswordHidden.value
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed:
                                        controller.toggleNewPasswordVisibility,
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      Obx(
                        () => ElevatedButton(
                          onPressed:
                              !controller.isValidating.value &&
                                  controller.isButtonEnabled.value
                              ? () {
                                  if (controller.step.value ==
                                      ForgotPasswordStep.inputEmail) {
                                    if (controller.emailC.text.isEmpty) {
                                      Get.snackbar(
                                        'Peringatan',
                                        'Email tidak boleh kosong',
                                      );
                                    } else {
                                      // TODO: implement inputEmailController
                                      controller.sendToken();
                                    }
                                  } else if (controller.step.value ==
                                      ForgotPasswordStep.tokenVerification) {
                                    if (controller.tokenC.text.isEmpty) {
                                      Get.snackbar(
                                        'Peringatan',
                                        'Token tidak boleh kosong',
                                      );
                                    } else {
                                      // TODO: implement tokenVerificationController
                                      controller.tokenVerification();
                                    }
                                  } else {
                                    if (controller.newPasswordC.text.isEmpty) {
                                      Get.snackbar(
                                        'Peringatan',
                                        'Password tidak boleh kosong',
                                      );
                                    } else {
                                      // TODO: implement newPasswordController
                                      controller.changePassword();
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            foregroundColor: Colors.white,
                            padding: controller.isValidating.value
                                ? EdgeInsets.symmetric(vertical: 10)
                                : EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: Colors.deepPurpleAccent.withValues(
                              alpha: 0.3,
                            ),
                          ),
                          child: controller.isValidating.value
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  controller.step.value ==
                                          ForgotPasswordStep.inputEmail
                                      ? 'Kirim Token'
                                      : controller.step.value ==
                                            ForgotPasswordStep.tokenVerification
                                      ? 'Verifikasi Token'
                                      : 'Ubah Password',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
