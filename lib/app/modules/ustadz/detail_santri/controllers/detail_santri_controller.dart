import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/modules/ustadz/daftar_santri/controllers/daftar_santri_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    getChart();
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
        Get.snackbar('Error', 'No authentication token found');
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
        final data = jsonDecode(response.body);
        final santri = s.Santri.fromJson(data['data']);
        santriDetail.value = santri;
        selectedTahap.value = santri.tahapHafalan ?? '';
        print('Santri detail loaded: ${santri.nama}');
      } else {
        Get.snackbar(
          'Error',
          'Failed to load santri detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getSantriDetail: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
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
        Get.snackbar('Success', 'Tahap hafalan updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update tahap hafalan');
      }
    } catch (e) {
      print('Error in updateTahapHafalan: $e');
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
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
      print(response.statusCode);
      print(data);
      if (response.statusCode == 200) {
        chart.value = c.Chart.fromJson(data);
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Gagal mendapatkan data chart',
        );
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred: $e');
    }
    isLoadingChart.value = false;
  }
}
