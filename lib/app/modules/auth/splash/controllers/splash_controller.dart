import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController {
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
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final role = prefs.getString('role');
      final userId = prefs.getString('userId');
      final roleId = prefs.getString('roleId');
      if (kDebugMode) {
        print(token);
        print(role);
        print('userId: $userId');
        print('roleId: $roleId');
      }
      if (token != null) {
        if (role == 'santri') {
          getSantri();
        } else if (role == 'ustadz') {
          getUstadz();
        } else if (role == 'ortu') {
          getOrtu();
        } else if (role == 'admin') {
          Get.offAllNamed('/admin-home');
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
              color: Color(0xFF6B46C1), // Purple color from your theme
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
                backgroundColor: const Color(0xFF6B46C1), // Purple color
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
      barrierDismissible:
          false, // Prevent dialog from being dismissed by tapping outside
    );
  }

  Future<void> getSantri() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final santriId = prefs.getString('roleId');
      final response = await get(
        Uri.parse(ApiUrl.santriDetail(santriId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        Get.offAllNamed('/santri-main');
      } else if (response.statusCode == 401) {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast(
          'Token tidak ditemukan\nSilakan login kembali',
        );
      } else {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast('Gagal memuat data\nSilakan login kembali');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }

  Future<void> getUstadz() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final ustadzId = prefs.getString('roleId');
      final response = await get(
        Uri.parse(ApiUrl.ustadzDetail(ustadzId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        Get.offAllNamed('/ustadz-main');
      } else if (response.statusCode == 401) {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast(
          'Token tidak ditemukan\nSilakan login kembali',
        );
      } else {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast('Gagal memuat data\nSilakan login kembali');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }

  void getOrtu() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final ortuId = prefs.getString('roleId');
      final response = await get(
        Uri.parse(ApiUrl.ortuDetail(ortuId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        Get.offAllNamed('/ortu-main');
      } else if (response.statusCode == 401) {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast(
          'Token tidak ditemukan\nSilakan login kembali',
        );
      } else {
        prefs.remove('token');
        prefs.remove('role');
        prefs.remove('userId');
        prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showErrorToast('Gagal memuat data\nSilakan login kembali');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }
}
