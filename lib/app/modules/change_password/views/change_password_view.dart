import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});
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
                Column(
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
                      'Ubah Password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        controller.step.value == ChangePasswordStep.oldPassword
                            ? 'Verifikasi Password Lama'
                            : 'Verifikasi Password Baru',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

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
                        () => Form(
                          key: controller.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.step.value ==
                                        ChangePasswordStep.oldPassword
                                    ? 'Password Lama'
                                    : 'Password Baru',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Old Password Field
                              if (controller.step.value ==
                                  ChangePasswordStep.oldPassword)
                                TextFormField(
                                  controller: controller.oldPasswordC,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password lama tidak boleh kosong';
                                    }
                                    if (value.length < 8) {
                                      return 'Password minimal 8 karakter';
                                    }
                                    return null;
                                  },
                                  obscureText:
                                      controller.isOldPasswordHidden.value,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Password Lama',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey[500],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isOldPasswordHidden.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: controller
                                          .toggleOldPasswordVisibility,
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
                                        color: Colors.deepPurpleAccent
                                            .withValues(alpha: 0.6),
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
                                  ChangePasswordStep.newPassword)
                                TextFormField(
                                  controller: controller.newPasswordC,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password baru tidak boleh kosong';
                                    }
                                    if (value.length < 8) {
                                      return 'Password minimal 8 karakter';
                                    }
                                    return null;
                                  },
                                  obscureText:
                                      controller.isNewPasswordHidden.value,
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan Password Baru',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey[500],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isNewPasswordHidden.value
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.grey[500],
                                      ),
                                      onPressed: controller
                                          .toggleNewPasswordVisibility,
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
                                        color: Colors.deepPurpleAccent
                                            .withValues(alpha: 0.6),
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
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Submit Button
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isValidating.value
                              ? null
                              : () {
                                  if (controller.step.value ==
                                      ChangePasswordStep.oldPassword) {
                                    if (controller.formKey.currentState!
                                        .validate()) {
                                      controller.changePasswordStep1(
                                        controller.oldPasswordC.text,
                                      );
                                    }
                                  } else {
                                    if (controller.formKey.currentState!
                                        .validate()) {
                                      controller.changePasswordStep2(
                                        controller.newPasswordC.text,
                                      );
                                    }
                                  }
                                },
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
                                          ChangePasswordStep.oldPassword
                                      ? 'Verifikasi'
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
