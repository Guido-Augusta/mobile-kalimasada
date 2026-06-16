import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

import '../../../../data/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final isConnectedToInternet = false.obs;
  StreamSubscription? _internetConnectionStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    _checkConnection();
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  void _checkConnection() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      final isConnected = await InternetConnection().hasInternetAccess;
      if (isConnected) {
        _handleConnectionStatus(InternetStatus.connected);
      } else {
        _handleConnectionStatus(InternetStatus.disconnected);
      }
    } catch (e) {
      _handleConnectionStatus(InternetStatus.disconnected);
    }
  }

  void _handleConnectionStatus(InternetStatus status) {
    switch (status) {
      case InternetStatus.connected:
        isConnectedToInternet.value = true;
        checkLoginStatus();
        break;
      case InternetStatus.disconnected:
        isConnectedToInternet.value = false;
        _showNoInternetDialog();
        break;
    }
  }

  void checkLoginStatus() async {
    try {
      final token = AuthService.to.token.value;
      final role = AuthService.to.roleString;
      final roleId = AuthService.to.roleId.value;

      if (token.isNotEmpty) {
        try {
          await _authRepository.checkAuth(role, roleId);
          // If successful, navigate to main page based on role
          if (role == 'santri') {
            Get.offAllNamed('/santri-main');
          } else if (role == 'ustadz') {
            Get.offAllNamed('/ustadz-main');
          } else if (role == 'ortu') {
            Get.offAllNamed('/ortu-main');
          } else if (role == 'admin') {
            Get.offAllNamed('/admin-main');
          } else {
            await AuthService.to.logout();
            Get.offAllNamed('/login');
          }
        } catch (e) {
          await AuthService.to.logout();
          Get.offAllNamed('/login');
          ToastUtils.showErrorToast(e.toString());
        }
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan status login');
    }
  }

  void _showNoInternetDialog() {
    Get.dialog(
      PopScope(
        onPopInvokedWithResult: (didPop, result) => false,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Peringatan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B46C1),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tidak dapat terhubung ke server. Pastikan perangkat Anda terhubung ke internet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => SystemNavigator.pop(), // Close the app
              style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
              child: const Text('Tutup Aplikasi'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                _checkConnection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B46C1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Muat Ulang',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
          actionsAlignment: MainAxisAlignment.spaceBetween,
        ),
      ),
      barrierDismissible: false,
    );
  }
}
