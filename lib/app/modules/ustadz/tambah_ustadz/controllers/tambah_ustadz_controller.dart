import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:path/path.dart' as path;

import '../../../../data/constants/app_constants.dart';
import '../../../../data/exceptions/app_exception.dart';
import '../../../../data/models/ustadz.dart';
import '../../../../data/repositories/ustadz_repository.dart';
import '../../../../utils/image_helper.dart';
import '../../../../utils/toast_utils.dart';
import '../../daftar_ustadz/controllers/daftar_ustadz_controller.dart';

class TambahUstadzController extends GetxController {
  final UstadzRepository _ustadzRepository = Get.find();

  final RxBool isUploadingImage = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSaveEmailPasswordLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  var ustadzDetail = Rxn<Ustadz>();

  final ImagePicker imagePicker = ImagePicker();
  var pickedImage = Rxn<XFile>();
  var defaultPhotoProfile = AppConstants.defaultProfileImageUrl.obs;

  GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  GlobalKey<FormFieldState> passwordFieldKey = GlobalKey<FormFieldState>();

  var emailC = TextEditingController();
  var passwordC = TextEditingController();

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController(text: 'L');
  var waliKelasTahapC = ''.obs;

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    namaC.dispose();
    noHpC.dispose();
    alamatC.dispose();
    jenisKelaminC.dispose();
    waliKelasTahapC.value = '';
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
    const lowerCase = "abcdefghijklmnopqrstuvwxyz";
    const upperCase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const numbers = "0123456789";
    const allowedChars = lowerCase + upperCase + numbers;

    final random = Random.secure();
    final charCodes = List.generate(length, (index) {
      return allowedChars.codeUnitAt(random.nextInt(allowedChars.length));
    });

    return String.fromCharCodes(charCodes);
  }

  String getImageUrl(String imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  void resetForm() {
    profileFormKey.currentState?.reset();
    passwordFieldKey.currentState?.reset();
    pickedImage.value = null;
    waliKelasTahapC.value = '';
    isPasswordVisible.value = false;
    emailC.clear();
    passwordC.clear();
    namaC.clear();
    noHpC.clear();
    alamatC.clear();
    jenisKelaminC.text = 'L';

    profileFormKey = GlobalKey<FormState>();
    passwordFieldKey = GlobalKey<FormFieldState>();
    update();
  }

  Future<void> addUstadz(
    XFile? fotoProfil,
    String? email,
    String? password,
    String? nama,
    String? noHp,
    String? jenisKelamin,
    String? alamat,
    String? waliKelasTahap,
  ) async {
    if (kDebugMode) {
      print(pickedImage.value?.path);
      print(emailC.text);
      print(passwordC.text);
      print(namaC.text);
      print(noHpC.text);
      print(jenisKelaminC.text);
      print(alamatC.text);
      print(waliKelasTahapC.value);
    }

    try {
      isSaveProfileLoading.value = true;

      // Prepare photo bytes if provided
      List<int>? fotoBytes;
      String? fotoFileName;
      String? fotoContentType;

      if (fotoProfil != null) {
        final file = File(fotoProfil.path);
        fotoBytes = await file.readAsBytes();
        final fileName = path.basename(fotoProfil.path);
        final extension = path.extension(fotoProfil.path).toLowerCase();

        // Ensure proper file extension
        fotoFileName = fileName;
        if (extension != '.jpg' &&
            extension != '.jpeg' &&
            extension != '.png') {
          fotoFileName =
              '${path.basenameWithoutExtension(fotoProfil.path)}.jpg';
        }

        fotoContentType = extension == '.png' ? 'image/png' : 'image/jpeg';
      }

      await _ustadzRepository.addUstadz(
        email: email!,
        password: password!,
        nama: nama!,
        noHp: noHp!,
        jenisKelamin: jenisKelamin!,
        alamat: alamat!,
        waliKelasTahap: waliKelasTahap!,
        fotoBytes: fotoBytes,
        fotoFileName: fotoFileName,
        fotoContentType: fotoContentType,
      );

      if (Get.isRegistered<DaftarUstadzController>()) {
        await Get.find<DaftarUstadzController>().fetchData();
      }
      if (Get.isRegistered<AdminHomeController>()) {
        await Get.find<AdminHomeController>().fetchTotals();
      }
      resetForm();
      ToastUtils.showSuccessToast(
        '${jenisKelamin.toLowerCase() == 'l' ? 'Ustadz' : 'Ustadzah'} berhasil ditambahkan',
      );
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      if (kDebugMode) {
        print('error: $e');
      }
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isSaveProfileLoading.value = false;
    }
  }
}
