import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/santri.dart';
import 'package:mobile_kalimasada/app/modules/santri/santri_home/controllers/santri_home_controller.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class SantriProfileController extends GetxController {
  var isLoading = false.obs;
  var isSaveLoading = false.obs;
  var santriDetail = Rxn<Santri>();
  String? santriId;

  final imagePicker = ImagePicker();
  var isUploadingImage = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController();
  var tanggalLahirC = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    santriId = prefs.getString('roleId');

    if (santriDetail.value?.tanggalLahir != null) {
      tanggalLahirC.text = DateFormat(
        'yyyy-MM-dd',
      ).format(santriDetail.value!.tanggalLahir!);
    }
    getSantriDetail(santriId!);
  }

  @override
  void onClose() {
    namaC.dispose();
    noHpC.dispose();
    alamatC.dispose();
    jenisKelaminC.dispose();
    tanggalLahirC.dispose();
    super.onClose();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  String getOrangTuaByTipe(List<OrangTua> orangTua, String tipe) {
    try {
      final orangTuaByTipe = orangTua.firstWhere(
        (element) => element.tipe?.toLowerCase() == tipe,
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
        final santri = Santri.fromJson(data['data']);
        santriDetail.value = santri;
        fotoProfil.value = getImageUrl(santri.fotoProfil!);
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

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedImage != null) {
        isUploadingImage.value = true;
        await uploadImage(pickedImage.path);
        print(pickedImage.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: $e');
    }
  }

  Future<void> uploadImage(String imagePath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final roleId = prefs.getString('roleId');

    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('http://10.0.2.2:5000/api/santri/$roleId'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['x-platform'] = 'mobile';

      // Read file and create multipart with proper content type
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final fileName = path.basename(imagePath);
      final extension = path.extension(imagePath).toLowerCase();

      // Ensure proper file extension
      String finalFileName = fileName;
      if (extension != '.jpg' && extension != '.jpeg' && extension != '.png') {
        finalFileName = '${path.basenameWithoutExtension(imagePath)}.jpg';
      }

      // Determine content type
      String contentType;
      if (extension == '.png') {
        contentType = 'image/png';
      } else {
        contentType = 'image/jpeg';
      }

      final multipartFile = http.MultipartFile.fromBytes(
        'fotoProfil',
        bytes,
        filename: finalFileName,
        contentType: MediaType.parse(contentType),
      );

      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['data']['fotoProfil'] != null) {
          fotoProfil.value = getImageUrl(data['data']['fotoProfil']);
        }

        if (Get.isRegistered<SantriHomeController>()) {
          Get.find<SantriHomeController>().getSantri();
        }

        Get.back();
        Get.snackbar('Success', 'Foto profil berhasil diperbarui');
      } else {
        Get.snackbar(
          'Error',
          'Gagal mengupload foto profil (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengupload foto profil: $e');
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> updateProfileData(
    String? nama,
    String? noHp,
    String? alamat,
    String? jenisKelamin,
    String? tanggalLahir,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final roleId = prefs.getString('roleId');
    try {
      isLoading.value = true;

      final response = await http.put(
        Uri.parse('http://10.0.2.2:5000/api/santri/$roleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'nama': nama ?? santriDetail.value?.nama,
          'nomorHp': noHp ?? santriDetail.value?.nomorHp,
          'alamat': alamat ?? santriDetail.value?.alamat,
          'jenisKelamin': jenisKelamin ?? santriDetail.value?.jenisKelamin,
          'tanggalLahir': tanggalLahir,
        }),
      );
      if (response.statusCode == 200) {
        getSantriDetail(roleId!);
        if (Get.isRegistered<SantriHomeController>()) {
          Get.find<SantriHomeController>().getSantri();
        }
        print(response.body);
        print('Tanggal Lahir: $tanggalLahir');
        Get.back();
        Get.snackbar('Success', 'Profil berhasil diperbarui');
      } else {
        Get.snackbar('Error', 'Gagal memuat data profil');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data profil');
    } finally {
      isLoading.value = false;
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
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
        Get.offAllNamed('/login');
        Get.snackbar('Success', 'Logout berhasil');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Logout gagal');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
