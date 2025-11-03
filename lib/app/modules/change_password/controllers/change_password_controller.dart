import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

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
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Token tidak ditemukan\nSilakan login kembali',
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
          autoCloseDuration: const Duration(milliseconds: 3000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/verify-old-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({'oldPassword': oldPassword}),
      );

      var data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200) {
        step.value = ChangePasswordStep.newPassword;
        oldPasswordVar.value = oldPassword;
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text(
                'Password lama berhasil diverifikasi',
                style: TextStyle(color: Colors.white),
              ),
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
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Verifikasi gagal', style: TextStyle(color: Colors.white)),
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
              'Terjadi kesalahan\nPeriksa koneksi internet Anda',
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
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Token tidak ditemukan\nSilakan login kembali',
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
          autoCloseDuration: const Duration(milliseconds: 3000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/change-password'),
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
      print(data);
      if (response.statusCode == 200) {
        logout();
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text(
                'Password berhasil diubah',
                style: TextStyle(color: Colors.white),
              ),
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
        showSuccessDialog();
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gagal mengubah password',
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
              'Terjadi kesalahan\nPeriksa koneksi internet Anda',
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
    } finally {
      isValidating.value = false;
    }
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/auth/logout/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      var data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Gagal logout', style: TextStyle(color: Colors.white)),
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
              'Terjadi kesalahan\nPeriksa koneksi internet Anda',
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
                            toastification.show(
                              context: Get.context!,
                              title: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Silahkan login kembali',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              icon: Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.green,
                              ),
                              showIcon: true,
                              backgroundColor: Color(0xFF6B6B6B),
                              borderSide: BorderSide.none,
                              alignment: Alignment.bottomCenter,
                              autoCloseDuration: const Duration(
                                milliseconds: 2000,
                              ),
                              closeButton: ToastCloseButton(
                                showType: CloseButtonShowType.none,
                              ),
                              animationBuilder:
                                  (context, animation, alignment, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                              type: ToastificationType.success,
                              style: ToastificationStyle.simple,
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
