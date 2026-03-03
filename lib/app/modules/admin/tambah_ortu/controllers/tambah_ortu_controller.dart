import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/constants/api_url.dart';
import '../../../../data/models/ortu.dart';
import '../../../../utils/toast_utils.dart';

class TambahOrtuController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSaveEmailPasswordLoading = false.obs;

  var ortuDetail = Rxn<Ortu>();

  final ImagePicker imagePicker = ImagePicker();
  var pickedImage = Rxn<XFile>();
  var defaultPhotoProfile =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  final profileFormKey = GlobalKey<FormState>();
  final emailPasswordFormKey = GlobalKey<FormState>();
  final ortuFormKey = GlobalKey<FormState>();

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController(text: 'L');
  var tipeC = TextEditingController(text: 'Ayah');

  final alamatFocusNode = FocusNode();

  var emailC = TextEditingController();
  var passwordC = TextEditingController();

  DateTime? lastErrorShown;

  @override
  void onClose() {
    alamatFocusNode.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    isUploadingImage.value = true;
    try {
      final image = await imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        pickedImage.value = image;
      }

      if (kDebugMode) {
        print('pickedImage.value?.path: ${pickedImage.value?.path}');
      }
    } catch (e) {
      ToastUtils.showErrorToast('Gagal memilih gambar');
    } finally {
      isUploadingImage.value = false;
    }
  }

  void deleteImage() {
    pickedImage.value = null;
  }

  String? validateEmail(String? email) {
    RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
    );
    if (email == null || email.isEmpty) {
      return 'Email tidak boleh kosong';
    } else if (!emailRegex.hasMatch(email)) {
      return 'Masukkan email yang valid';
    }
    return null;
  }

  String generatePassword({int length = 8}) {
    // 1. Tentukan karakter apa saja yang boleh dipakai
    const lowerCase = "abcdefghijklmnopqrstuvwxyz";
    const upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbers = "0123456789";

    // Gabungkan semua jadi satu string panjang
    const allowedChars = lowerCase + upperCase + numbers;

    // 2. Gunakan Random.secure() untuk keamanan tinggi
    final random = Random.secure();

    // 3. Generate password
    final charCodes = List.generate(length, (index) {
      // Ambil posisi random dari allowedChars
      return allowedChars.codeUnitAt(random.nextInt(allowedChars.length));
    });

    return String.fromCharCodes(charCodes);
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  void resetForm() {
    emailC.clear();
    passwordC.clear();
    namaC.clear();
    noHpC.clear();
    alamatC.clear();
    jenisKelaminC.text = 'L';
    tipeC.text = 'Ayah';

    emailPasswordFormKey.currentState?.reset();
    profileFormKey.currentState?.reset();
    ortuFormKey.currentState?.reset();
    pickedImage.value = null;
  }

  Future<void> addOrtu(
    XFile? fotoProfil,
    String? email,
    String? password,
    String? nama,
    String? noHp,
    String? jenisKelamin,
    String? tipe,
    String? alamat,
  ) async {
    try {
      isSaveProfileLoading.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final request = http.MultipartRequest('POST', Uri.parse(ApiUrl.ortu));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['x-platform'] = 'mobile';

      request.fields['email'] = email!;
      request.fields['password'] = password!;
      request.fields['nama'] = nama!;
      request.fields['nomorHp'] = noHp!;
      request.fields['jenisKelamin'] = jenisKelamin!;
      request.fields['tipe'] = tipe!;
      request.fields['alamat'] = alamat!;

      if (fotoProfil != null) {
        // Read file and create multipart with proper content type
        final file = File(fotoProfil.path);
        final bytes = await file.readAsBytes();
        final fileName = path.basename(fotoProfil.path);
        final extension = path.extension(fotoProfil.path).toLowerCase();

        // Ensure proper file extension
        String finalFileName = fileName;
        if (extension != '.jpg' &&
            extension != '.jpeg' &&
            extension != '.png') {
          finalFileName =
              '${path.basenameWithoutExtension(fotoProfil.path)}.jpg';
        }
        if (kDebugMode) {
          print('final file name: $finalFileName');
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
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (kDebugMode) {
          print(data);
        }
        // Reset Form
        resetForm();
        Get.offNamed('/tambah-ortu');
        ToastUtils.showSuccessToast('$tipe berhasil ditambahkan');
      } else if (response.statusCode == 400) {
        final parsed = jsonDecode(responseBody);
        final message = parsed['message'];
        ToastUtils.showErrorToast(message);
      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(responseBody);
        }
        ToastUtils.showErrorToast('Gagal menambahkan data $tipe');
      }
    } catch (e) {
      final now = DateTime.now();
      if (lastErrorShown == null ||
          now.difference(lastErrorShown!) > Duration(seconds: 3)) {
        lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isSaveProfileLoading.value = false;
    }
  }
}
