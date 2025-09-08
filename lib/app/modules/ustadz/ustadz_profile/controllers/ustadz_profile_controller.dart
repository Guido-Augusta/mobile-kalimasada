import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/models/ustadz.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UstadzProfileController extends GetxController {
  final isLoading = true.obs;
  var ustadzData = Rxn<Ustadz>();
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  @override
  void onInit() {
    super.onInit();
    fetchUstadzData();
  }

  Future<void> fetchUstadzData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final roleId = prefs.getString('roleId');
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/ustadz/$roleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ustadz = Ustadz.fromJson(data['data']);
        ustadzData.value = ustadz;
        fotoProfil.value = getImageUrl(ustadz.fotoProfil!);
      } else {
        Get.snackbar('Error', 'Gagal memuat data profil');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data profil');
    } finally {
      isLoading.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  void navigateToEditProfile() {
    // TODO: Implement navigation to edit profile
    Get.snackbar('Info', 'Edit profile akan segera tersedia');
  }
}
