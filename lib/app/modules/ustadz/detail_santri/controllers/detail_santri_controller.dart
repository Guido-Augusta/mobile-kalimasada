import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/modules/ustadz/daftar_santri/controllers/daftar_santri_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

enum ChartType { hafalanBaru, murajaah }

class DetailSantriController extends GetxController {
  var isLoading = false.obs;
  var isSaveLoading = false.obs;
  var santriDetail = Rxn<s.Santri>();
  var santriId = Get.arguments;
  String userRole = '';

  var selectedTahap = ''.obs;

  var isLoadingChart = false.obs;
  var chart = Rxn<c.Chart>();
  var range = '1w'.obs;
  var selectedChartType = ChartType.hafalanBaru.obs;

  @override
  void onInit() {
    super.onInit();
    getSantriDetail(santriId);
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  String getOrangTuaByTipe(List<s.OrangTua> orangTua, String tipe) {
    try {
      final orangTuaByTipe = orangTua.firstWhere(
        (element) => element.tipe == tipe,
      );
      return orangTuaByTipe.nama ?? '-';
    } catch (e) {
      return '-';
    }
  }

  Future<void> getSantriDetail(String id) async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      userRole = prefs.getString('role') ?? '';

      if (token == null) {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Anda tidak terautentikasi',
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
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/santri/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        getChart();
        final data = jsonDecode(response.body);
        final santri = s.Santri.fromJson(data['data']);
        santriDetail.value = santri;
        selectedTahap.value = santri.tahapHafalan ?? '';
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
                'Gagal mendapatkan data santri',
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
          autoCloseDuration: const Duration(milliseconds: 1500),
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
        autoCloseDuration: const Duration(milliseconds: 1500),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateTahapHafalan(String tahapHafalan) async {
    isSaveLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/santri/$santriId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'tahapHafalan': tahapHafalan, // Level1, Level2, Level3
        }),
      );
      if (response.statusCode == 200) {
        getSantriDetail(santriId);
        if (Get.isRegistered<DaftarSantriController>()) {
          Get.find<DaftarSantriController>().fetchData();
        }
        Get.back();
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text(
                'Tahap hafalan berhasil diperbarui',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
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
              Text(
                'Gagal memperbarui tahap hafalan',
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
          autoCloseDuration: const Duration(milliseconds: 1500),
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
        autoCloseDuration: const Duration(milliseconds: 1500),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isSaveLoading.value = false;
    }
  }

  void getChart() async {
    isLoadingChart.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/chart?range=$range&santriId=$santriId',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        chart.value = c.Chart.fromJson(data);
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
                'Gagal mendapatkan data chart',
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
          autoCloseDuration: const Duration(milliseconds: 1500),
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
        autoCloseDuration: const Duration(milliseconds: 1500),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    }
    isLoadingChart.value = false;
  }
}
