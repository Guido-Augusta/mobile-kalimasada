import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_ortu.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/daftar_santri/controllers/daftar_santri_controller.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/santri.dart';
import '../../../../data/models/santri.dart' as s;

class EditSantriController extends GetxController {
  final String santriId = Get.arguments['santriId'];

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSaveEmailPasswordLoading = false.obs;

  var santriDetail = Rxn<Santri>();

  final ImagePicker imagePicker = ImagePicker();
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  final profileFormKey = GlobalKey<FormState>();
  final emailPasswordFormKey = GlobalKey<FormState>();

  var namaC = TextEditingController();
  var noIndukC = TextEditingController();
  var noHpC = TextEditingController();
  var tanggalLahirC = TextEditingController();
  var jenisKelaminC = TextEditingController(text: 'L');
  var alamatC = TextEditingController();
  var tahapHafalanC = TextEditingController(text: 'Level1');

  var emailC = TextEditingController();
  var passwordC = TextEditingController();

  var selectedAyah = Rxn<Datum>();
  var selectedIbu = Rxn<Datum>();
  var selectedWali = Rxn<Datum>();

  final santriDummy = Santri(
    id: 0,
    userId: 0,
    nama: 'Loading...',
    tahapHafalan: '',
    orangTua: [],
    totalPoin: 0,
    peringkat: 0,
    createdAt: DateTime.now(),
    poinUpdatedAt: DateTime.now(),
    user: null,
    waliKelas: [],
  );

  DateTime? lastErrorShown;
  DateTime? _lastNoChangeShown;

  @override
  void onInit() async {
    super.onInit();
    getSantriDetail();
  }

  @override
  void onClose() {
    namaC.dispose();
    noIndukC.dispose();
    noHpC.dispose();
    alamatC.dispose();
    jenisKelaminC.dispose();
    tanggalLahirC.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  Future<void> getSantriDetail({bool isReload = true}) async {
    try {
      isLoading.value = isReload;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(ApiUrl.santriDetail(santriId)),
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

        // Initialize text controllers with current values
        namaC.text = santriDetail.value!.nama!;
        tahapHafalanC.text = santriDetail.value!.tahapHafalan!;

        emailC.text = santriDetail.value!.user!.email!;

        // Set selected items
        selectedAyah.value = convertOrangTuaToDatum(
          getOrangTuaByTipe(santriDetail.value!.orangTua, 'Ayah'),
        );
        selectedIbu.value = convertOrangTuaToDatum(
          getOrangTuaByTipe(santriDetail.value!.orangTua, 'Ibu'),
        );
        selectedWali.value = convertOrangTuaToDatum(
          getOrangTuaByTipe(santriDetail.value!.orangTua, 'Wali'),
        );
        if (kDebugMode) {
          print('Santri detail loaded: ${santri.nama}');
        }
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting santri detail: $e');
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

  s.OrangTua? getOrangTuaByTipe(List<s.OrangTua> orangTua, String tipe) {
    if (orangTua.isEmpty) return null;
    try {
      final result = orangTua.where(
        (element) => element.tipe?.toLowerCase() == tipe.toLowerCase(),
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  // Method untuk mendapatkan selected item berdasarkan tipe
  Datum? getSelectedOrtuByTipe(String tipe) {
    switch (tipe.toLowerCase()) {
      case 'ayah':
        return selectedAyah.value;
      case 'ibu':
        return selectedIbu.value;
      case 'wali':
        return selectedWali.value;
      default:
        return null;
    }
  }

  // Method untuk mengkonversi OrangTua ke Datum
  Datum? convertOrangTuaToDatum(s.OrangTua? orangTua) {
    if (orangTua == null) return null;

    return Datum(
      id: orangTua.id,
      userId: null,
      nama: orangTua.nama,
      nomorHp: null,
      alamat: null,
      jenisKelamin: null,
      fotoProfil: null,
      tipe: orangTua.tipe,
      user: null,
    );
  }

  // Method untuk search orang tua
  Future<List<Datum>> loadOrtuByTipe(String tipe, String? query) async {
    try {
      isSearching.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final queryParams = {
        'page': '1',
        'limit': '200',
        'tipe': tipe,
        'search': query,
      };

      final uri = Uri.parse(ApiUrl.ortu).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final daftarOrtu = DaftarOrtu.fromJson(data);
        return daftarOrtu.data;
      } else {
        ToastUtils.showErrorToast('Gagal mencari orang tua');
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching ortu: $e');
      }
      final now = DateTime.now();
      if (lastErrorShown == null ||
          now.difference(lastErrorShown!) > Duration(seconds: 3)) {
        lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
      return [];
    } finally {
      isSearching.value = false;
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

      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(ApiUrl.santriDetail(santriId)),
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
        if (Get.isRegistered<DaftarSantriController>()) {
          await Get.find<DaftarSantriController>().fetchData();
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

  Future<void> updateProfileSantri(
    String? nama,
    String? noInduk,
    String? noHp,
    String? alamat,
    String? jenisKelamin,
    String? tanggalLahir,
    String? tahapHafalan,
    Datum? selectedAyah,
    Datum? selectedIbu,
    Datum? selectedWali,
  ) async {
    try {
      bool hasNoChange =
          (nama == santriDetail.value?.nama &&
          tahapHafalan == santriDetail.value?.tahapHafalan &&
          selectedAyah?.id ==
              getOrangTuaIdByTipe(santriDetail.value!.orangTua, 'Ayah') &&
          selectedIbu?.id ==
              getOrangTuaIdByTipe(santriDetail.value!.orangTua, 'Ibu') &&
          selectedWali?.id ==
              getOrangTuaIdByTipe(santriDetail.value!.orangTua, 'Wali'));

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

      List<int> listIdOrtu = [];
      if (selectedAyah != null) {
        listIdOrtu.add(selectedAyah.id!);
      }
      if (selectedIbu != null) {
        listIdOrtu.add(selectedIbu.id!);
      }
      if (selectedWali != null) {
        listIdOrtu.add(selectedWali.id!);
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http
          .put(
            Uri.parse(ApiUrl.santriDetail(santriId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
            body: jsonEncode({
              'nama': nama ?? santriDetail.value?.nama,
              'tahapHafalan': tahapHafalan ?? santriDetail.value?.tahapHafalan,
              'ortuId': listIdOrtu,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        await getSantriDetail(isReload: false);
        if (Get.isRegistered<DaftarSantriController>()) {
          await Get.find<DaftarSantriController>().fetchData();
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

  Future<void> updateEmailPasswordSantri(
    String? email,
    String? password,
  ) async {
    try {
      isSaveEmailPasswordLoading.value = true;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http
          .put(
            Uri.parse(ApiUrl.santriDetail(santriId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        await getSantriDetail(isReload: false);
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

  // Format the date to display in the text field
  String formatDateToDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String convertDisplayToApiFormat(String displayDate) {
    try {
      final parts = displayDate.split('/');
      if (parts.length == 3) {
        return '${parts[2]}-${parts[1]}-${parts[0]}'; // DD/MM/YYYY -> YYYY-MM-DD
      }
      return displayDate;
    } catch (e) {
      return displayDate;
    }
  }

  int? getOrangTuaIdByTipe(List<s.OrangTua> orangTua, String tipe) {
    if (orangTua.isEmpty) return null;
    try {
      final result = orangTua.where(
        (element) => element.tipe?.toLowerCase() == tipe.toLowerCase(),
      );
      return result.isNotEmpty ? result.first.id : null;
    } catch (e) {
      return null;
    }
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
