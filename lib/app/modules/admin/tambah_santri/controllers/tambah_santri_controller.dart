import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/constants/api_url.dart';
import '../../../../data/models/daftar_ortu.dart';
import '../../../../data/models/santri.dart';
import '../../../ustadz/daftar_santri/controllers/daftar_santri_controller.dart';

class TambahSantriController extends GetxController {
  final RxBool isUploadingImage = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSaveEmailPasswordLoading = false.obs;

  var santriDetail = Rxn<Santri>();

  final ImagePicker imagePicker = ImagePicker();
  var pickedImage = Rxn<XFile>();
  var defaultPhotoProfile =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> ortuFormKey = GlobalKey<FormState>();
  var passwordFieldKey = GlobalKey<FormFieldState>();
  var ayahDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
  var ibuDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
  var waliDropdownKey = GlobalKey<DropdownSearchState<Datum>>();

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

  DateTime? lastErrorShown;

  @override
  void onClose() {
    namaC.dispose();
    noIndukC.dispose();
    noHpC.dispose();
    tanggalLahirC.dispose();
    jenisKelaminC.dispose();
    alamatC.dispose();
    tahapHafalanC.dispose();
    emailC.dispose();
    passwordC.dispose();
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

  // Function to show date picker
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggalLahirC.text.isNotEmpty
          ? DateTime.parse(convertDisplayToApiFormat(tanggalLahirC.text))
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.deepPurple,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      tanggalLahirC.text = formatDateToDisplay(picked);
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

  Future<void> addSantri(
    XFile? fotoProfil,
    String? email,
    String? password,
    String? nama,
    String? noInduk,
    String? noHp,
    String? jenisKelamin,
    String? tanggalLahir,
    String? alamat,
    Datum? selectedAyah,
    Datum? selectedIbu,
    Datum? selectedWali,
    String? tahapHafalan,
  ) async {
    try {
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

      if (kDebugMode) {
        print(listIdOrtu);
      }

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final request = http.MultipartRequest('POST', Uri.parse(ApiUrl.santri));
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['x-platform'] = 'mobile';

      request.fields['email'] = email!;
      request.fields['password'] = password!;
      request.fields['ortuId'] = jsonEncode(listIdOrtu);
      request.fields['nama'] = nama!;
      request.fields['noInduk'] = noInduk!;
      request.fields['nomorHp'] = noHp!;
      request.fields['tanggalLahir'] = convertDisplayToApiFormat(tanggalLahir!);
      request.fields['jenisKelamin'] = jenisKelamin!;
      request.fields['alamat'] = alamat!;
      request.fields['tahapHafalan'] = tahapHafalan!;

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
        resetForm();
        if (Get.isRegistered<DaftarSantriController>()) {
          await Get.find<DaftarSantriController>().fetchData();
        }
        ToastUtils.showSuccessToast('Santri berhasil ditambahkan');
      } else if (response.statusCode == 400) {
        final parsed = jsonDecode(responseBody);
        final message = parsed['message'];
        ToastUtils.showErrorToast(message);
      } else {
        if (kDebugMode) {
          print(response.statusCode);
          print(responseBody);
        }
        ToastUtils.showErrorToast('Gagal menambahkan data santri');
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

  void resetForm() {
    pickedImage.value = null;
    emailC.clear();
    passwordC.clear();
    namaC.clear();
    noIndukC.clear();
    noHpC.clear();
    tanggalLahirC.clear();
    alamatC.clear();
    jenisKelaminC.text = 'L';
    tahapHafalanC.text = 'Level1';

    selectedAyah.value = null;
    selectedIbu.value = null;
    selectedWali.value = null;

    ortuFormKey = GlobalKey<FormState>();
    profileFormKey = GlobalKey<FormState>();
    passwordFieldKey = GlobalKey<FormFieldState>();
    ayahDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
    ibuDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
    waliDropdownKey = GlobalKey<DropdownSearchState<Datum>>();
    update();
  }
}
