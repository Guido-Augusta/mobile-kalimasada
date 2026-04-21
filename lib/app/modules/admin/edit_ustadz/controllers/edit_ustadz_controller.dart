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
import '../../../../data/models/ustadz.dart';
import '../../../../utils/toast_utils.dart';
import '../../daftar_ustadz/controllers/daftar_ustadz_controller.dart';

class EditUstadzController extends GetxController {
  final String ustadzId = Get.arguments['ustadzId'];

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSaveEmailPasswordLoading = false.obs;

  var ustadzDetail = Rxn<Ustadz>();

  final ImagePicker imagePicker = ImagePicker();
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  final profileFormKey = GlobalKey<FormState>();
  final emailPasswordFormKey = GlobalKey<FormState>();

  var emailC = TextEditingController();
  var passwordC = TextEditingController();

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController(text: 'L');
  var waliKelasTahapC = ''.obs;

  DateTime? lastErrorShown;
  DateTime? _lastNoChangeShown;

  @override
  void onInit() async {
    super.onInit();
    getUstadzDetail();
  }

  Future<void> getUstadzDetail({bool isReload = true}) async {
    try {
      isLoading.value = isReload;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.ustadzDetail(ustadzId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ustadz = Ustadz.fromJson(data['data']);
        ustadzDetail.value = ustadz;
        if (ustadz.fotoProfil != null && ustadz.fotoProfil!.isNotEmpty) {
          fotoProfil.value = getImageUrl(ustadz.fotoProfil!);
        }

        // Initialize text controllers with current values
        namaC.text = ustadzDetail.value!.nama!;
        noHpC.text = ustadzDetail.value!.nomorHp!;
        alamatC.text = ustadzDetail.value!.alamat!;
        jenisKelaminC.text = ustadzDetail.value!.jenisKelamin!;
        waliKelasTahapC.value = ustadzDetail.value?.waliKelasTahap ?? '';

        emailC.text = ustadzDetail.value!.user!.email!;

        if (kDebugMode) {
          print('Ustadz detail loaded: ${ustadz.nama}');
        }
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting ustadz/ah detail: $e');
      }
      final now = DateTime.now();
      if (lastErrorShown == null ||
          now.difference(lastErrorShown!) > Duration(seconds: 3)) {
        lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
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

  void deleteImage() async {
    try {
      bool? confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Hapus Foto Profil'),
          content: const Text('Apakah Anda yakin ingin menghapus foto profil?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      isUploadingImage.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiUrl.ustadzDetail(ustadzId)),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['x-platform'] = 'mobile';

      final emptyFile = http.MultipartFile.fromString(
        'fotoProfil',
        '',
        filename: 'empty.jpg',
        contentType: MediaType.parse('image/jpeg'),
      );
      request.files.add(emptyFile);

      final response = await request.send();

      if (response.statusCode == 200) {
        // Reset ke foto default
        fotoProfil.value = getImageUrl(
          'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg',
        );

        await getUstadzDetail(isReload: false);
        ToastUtils.showSuccessToast('Foto profil berhasil dihapus');
      } else {
        ToastUtils.showErrorToast('Gagal menghapus foto profil');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image: $e');
      }
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> uploadImage(String imagePath) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiUrl.ustadzDetail(ustadzId)),
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

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        if (data['data']['fotoProfil'] != null) {
          fotoProfil.value = getImageUrl(data['data']['fotoProfil']);
        }
        if (Get.isRegistered<DaftarUstadzController>()) {
          await Get.find<DaftarUstadzController>().fetchData();
        }

        ToastUtils.showSuccessToast('Foto profil berhasil diperbarui');
      } else {
        ToastUtils.showErrorToast('Gagal mengupload foto profil');
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> updateProfileUstadz(
    String? nama,
    String? noHp,
    String? alamat,
    String? jenisKelamin,
    String? waliKelasTahap,
  ) async {
    try {
      bool hasNoChange =
          (nama == ustadzDetail.value?.nama &&
          noHp == ustadzDetail.value?.nomorHp &&
          alamat == ustadzDetail.value?.alamat &&
          jenisKelamin == ustadzDetail.value?.jenisKelamin &&
          waliKelasTahap == ustadzDetail.value?.waliKelasTahap);

      if (hasNoChange) {
        final now = DateTime.now();
        if (_lastNoChangeShown == null ||
            now.difference(_lastNoChangeShown!) > Duration(seconds: 3)) {
          _lastNoChangeShown = now;
          ToastUtils.showErrorToast('Tidak ada perubahan data');
        }
        return;
      }
      isSaveProfileLoading.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http
          .put(
            Uri.parse(ApiUrl.ustadzDetail(ustadzId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
            body: jsonEncode({
              'nama': nama ?? ustadzDetail.value?.nama,
              'nomorHp': noHp ?? ustadzDetail.value?.nomorHp,
              'alamat': alamat ?? ustadzDetail.value?.alamat,
              'jenisKelamin': jenisKelamin ?? ustadzDetail.value?.jenisKelamin,
              'waliKelasTahap':
                  waliKelasTahap ?? ustadzDetail.value?.waliKelasTahap,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        await getUstadzDetail(isReload: false);
        if (Get.isRegistered<DaftarUstadzController>()) {
          await Get.find<DaftarUstadzController>().fetchData();
        }
        ToastUtils.showSuccessToast('Profil berhasil diperbarui');
      } else {
        ToastUtils.showErrorToast('Gagal memperbarui data profil');
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

  Future<void> updateEmailPasswordUstadz(
    String? email,
    String? password,
  ) async {
    try {
      isSaveEmailPasswordLoading.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http
          .put(
            Uri.parse(ApiUrl.ustadzDetail(ustadzId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        await getUstadzDetail(isReload: false);
        Get.back();
        ToastUtils.showSuccessToast('Email dan password berhasil diperbarui');
      } else {
        final now = DateTime.now();
        if (lastErrorShown == null ||
            now.difference(lastErrorShown!) > Duration(seconds: 3)) {
          lastErrorShown = now;
          ToastUtils.showErrorToast('Gagal memperbarui email dan password');
        }
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
      isSaveEmailPasswordLoading.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
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
}
