import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../../data/constants/app_constants.dart';
import '../../../../data/exceptions/app_exception.dart';
import '../../../../data/models/ustadz.dart';
import '../../../../data/repositories/ustadz_repository.dart';
import '../../../../utils/image_helper.dart';
import '../../../../utils/toast_utils.dart';
import '../../daftar_ustadz/controllers/daftar_ustadz_controller.dart';

class EditUstadzController extends GetxController {
  final UstadzRepository _ustadzRepository = Get.find();

  final String ustadzId = Get.arguments['ustadzId'];

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSaveEmailPasswordLoading = false.obs;

  final RxBool isPasswordVisible = false.obs;
  var ustadzDetail = Rxn<Ustadz>();

  final ImagePicker imagePicker = ImagePicker();
  var fotoProfil = AppConstants.defaultProfileImageUrl.obs;

  final profileFormKey = GlobalKey<FormState>();
  final emailPasswordFormKey = GlobalKey<FormState>();
  final passwordFieldKey = GlobalKey<FormFieldState>();

  var emailC = TextEditingController();
  var passwordC = TextEditingController();

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController(text: 'L');
  var waliKelasTahapC = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getUstadzDetail();
  }

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    namaC.dispose();
    noHpC.dispose();
    alamatC.dispose();
    jenisKelaminC.dispose();
    super.onClose();
  }

  Future<void> getUstadzDetail({bool isReload = true}) async {
    try {
      isLoading.value = isReload;
      final ustadz = await _ustadzRepository.getUstadz(ustadzId);
      ustadzDetail.value = ustadz;

      if (ustadz.fotoProfil != null && ustadz.fotoProfil!.isNotEmpty) {
        fotoProfil.value = ImageHelper.getImageUrl(ustadz.fotoProfil!);
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
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
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
      String contentType = extension == '.png' ? 'image/png' : 'image/jpeg';

      final ustadz = await _ustadzRepository.uploadFotoProfil(
        ustadzId: ustadzId,
        bytes: bytes,
        fileName: finalFileName,
        contentType: contentType,
      );

      if (ustadz.fotoProfil != null) {
        fotoProfil.value = ImageHelper.getImageUrl(ustadz.fotoProfil!);
      }

      if (Get.isRegistered<DaftarUstadzController>()) {
        await Get.find<DaftarUstadzController>().fetchData();
      }

      ToastUtils.showSuccessToast('Foto profil berhasil diperbarui');
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
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
        ToastUtils.showErrorToast('Tidak ada perubahan data');
        return;
      }

      isSaveProfileLoading.value = true;

      await _ustadzRepository.updateProfile(
        ustadzId,
        nama ?? ustadzDetail.value!.nama!,
        noHp ?? ustadzDetail.value!.nomorHp!,
        alamat ?? ustadzDetail.value!.alamat!,
        jenisKelamin ?? ustadzDetail.value!.jenisKelamin!,
        waliKelasTahap ?? ustadzDetail.value?.waliKelasTahap ?? '',
      );

      await getUstadzDetail(isReload: false);
      if (Get.isRegistered<DaftarUstadzController>()) {
        await Get.find<DaftarUstadzController>().fetchData();
      }
      ToastUtils.showSuccessToast('Profil berhasil diperbarui');
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isSaveProfileLoading.value = false;
    }
  }

  Future<void> updateEmailPasswordUstadz(
    String? email,
    String? password,
  ) async {
    try {
      bool hasNoChange =
          (email == ustadzDetail.value?.user?.email &&
          (password == null || password.isEmpty));

      if (hasNoChange) {
        ToastUtils.showErrorToast('Tidak ada perubahan data');
        return;
      }

      isSaveEmailPasswordLoading.value = true;

      String oldEmail = ustadzDetail.value?.user?.email ?? "";
      bool emailChanged = email != oldEmail;
      bool passwordChanged = password != null && password.isNotEmpty;

      await _ustadzRepository.updateEmailPassword(ustadzId, email, password);

      await getUstadzDetail(isReload: false);
      Get.back();

      if (emailChanged && passwordChanged) {
        ToastUtils.showSuccessToast('Email dan password berhasil diperbarui');
      } else if (emailChanged) {
        ToastUtils.showSuccessToast('Email berhasil diperbarui');
      } else if (passwordChanged) {
        ToastUtils.showSuccessToast('Password berhasil diperbarui');
      } else {
        ToastUtils.showSuccessToast('Data berhasil diperbarui');
      }
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isSaveEmailPasswordLoading.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
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
}
