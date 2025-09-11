import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailSantriController extends GetxController {
  var isLoading = false.obs;
  var santriDetail = Rxn<DaftarSantri>();
  var santriId = Get.arguments;

  @override
  void onInit() {
    super.onInit();
    getSantriDetail(santriId);
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getSantriDetail(String id) async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

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
        final santri = DaftarSantri.fromJson(data['data']);
        santriDetail.value = santri;
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
}
