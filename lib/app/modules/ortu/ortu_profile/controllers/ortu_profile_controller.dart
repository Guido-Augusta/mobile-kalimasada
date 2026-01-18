import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/controllers/ortu_home_controller.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class OrtuProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isSaveLoading = false.obs;
  var ortuDetail = Rxn<Ortu>();
  String? ortuId;
  String? userRole;

  final imagePicker = ImagePicker();
  var isUploadingImage = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();

  @override
  void onInit() async {
    super.onInit();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ortuId = prefs.getString('roleId');
    userRole = prefs.getString('role');
    getOrtuDetail(ortuId!);
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getOrtuDetail(String ortuId) async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.ortu(ortuId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ortu = Ortu.fromJson(data['data']);
        ortuDetail.value = ortu;
        fotoProfil.value = getImageUrl(ortu.fotoProfil!);
        if (kDebugMode) {
          print('Ortu detail loaded: ${ortu.nama}');
        }
      } else {
        ToastUtils.showErrorToast('Gagal memuat data profil');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
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
        if (kDebugMode) {
          print(pickedImage.path);
        }
      }
    } catch (e) {
      ToastUtils.showErrorToast('Gagal memilih gambar');
    }
  }

  Future<void> uploadImage(String imagePath) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final ortuId = prefs.getString('roleId');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiUrl.ortu(ortuId!)),
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

        if (Get.isRegistered<OrtuHomeController>()) {
          Get.find<OrtuHomeController>().getOrtu();
        }

        Get.back();
        ToastUtils.showSuccessToast('Foto profil berhasil diperbarui');
      } else {
        ToastUtils.showErrorToast('Gagal mengupload foto profil');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> updateProfileData(
    String? nama,
    String? noHp,
    String? alamat,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ortuId = prefs.getString('roleId');
    try {
      isLoading.value = true;

      final response = await http.put(
        Uri.parse(ApiUrl.ortu(ortuId!)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'nama': nama ?? ortuDetail.value?.nama,
          'nomorHp': noHp ?? ortuDetail.value?.nomorHp,
          'alamat': alamat ?? ortuDetail.value?.alamat,
        }),
      );
      if (response.statusCode == 200) {
        getOrtuDetail(ortuId);
        if (Get.isRegistered<OrtuHomeController>()) {
          Get.find<OrtuHomeController>().getOrtu();
        }
        if (kDebugMode) {
          print(response.body);
        }
        Get.back();
        ToastUtils.showSuccessToast('Profil berhasil diperbarui');
      } else {
        ToastUtils.showErrorToast('Gagal memperbarui profil');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      final response = await http.post(
        Uri.parse(ApiUrl.logout(userId!)),
        headers: {'Content-Type': 'application/json'},
      );
      var data = jsonDecode(response.body);
      if (kDebugMode) {
        print(data);
      }
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showSuccessToast('Logout berhasil');
      } else {
        ToastUtils.showErrorToast('Logout gagal');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }
}
