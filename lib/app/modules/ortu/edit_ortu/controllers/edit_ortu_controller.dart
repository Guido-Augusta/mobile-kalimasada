import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../../data/constants/app_constants.dart';
import '../../../../data/exceptions/app_exception.dart';
import '../../../../data/models/ortu.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../../../../utils/image_helper.dart';
import '../../../../utils/toast_utils.dart';
import '../../daftar_ortu/controllers/daftar_ortu_controller.dart';

class EditOrtuController extends GetxController {
  final OrtuRepository _ortuRepository = Get.find();

  final String ortuId = Get.arguments['ortuId'];

  final RxBool isLoading = false.obs;
  final RxBool isUploadingImage = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isSaveProfileLoading = false.obs;
  final RxBool isSaveEmailPasswordLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;

  var ortuDetail = Rxn<Ortu>();

  final ImagePicker imagePicker = ImagePicker();
  var fotoProfil = AppConstants.defaultProfileImageUrl.obs;

  final profileFormKey = GlobalKey<FormState>();
  final emailPasswordFormKey = GlobalKey<FormState>();
  final passwordFieldKey = GlobalKey<FormFieldState>();

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController(text: 'L');
  var tipeC = TextEditingController(text: 'Ayah');

  final alamatFocusNode = FocusNode();

  var emailC = TextEditingController();
  var passwordC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    getOrtuDetail();
  }

  @override
  void onClose() {
    namaC.dispose();
    noHpC.dispose();
    alamatC.dispose();
    jenisKelaminC.dispose();
    tipeC.dispose();
    alamatFocusNode.dispose();
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  Future<void> getOrtuDetail({bool isReload = true}) async {
    try {
      isLoading.value = isReload;
      final ortu = await _ortuRepository.getOrtuDetail(ortuId);
      ortuDetail.value = ortu;

      if (ortu.fotoProfil != null && ortu.fotoProfil!.isNotEmpty) {
        fotoProfil.value = ImageHelper.getImageUrl(ortu.fotoProfil!);
      }

      // Initialize text controllers with current values
      namaC.text = ortuDetail.value!.nama!;
      noHpC.text = ortuDetail.value!.nomorHp!;
      alamatC.text = ortuDetail.value!.alamat!;
      jenisKelaminC.text = ortuDetail.value!.jenisKelamin!;
      tipeC.text = ortuDetail.value!.tipe!;

      emailC.text = ortuDetail.value!.user!.email!;

      if (kDebugMode) {
        print('Ortu detail loaded: ${ortu.nama}');
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

      final ortu = await _ortuRepository.uploadFotoProfil(
        ortuId: ortuId,
        bytes: bytes,
        fileName: finalFileName,
        contentType: contentType,
      );

      if (ortu.fotoProfil != null) {
        fotoProfil.value = ImageHelper.getImageUrl(ortu.fotoProfil!);
      }

      if (Get.isRegistered<DaftarOrtuController>()) {
        await Get.find<DaftarOrtuController>().fetchData();
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

  Future<void> updateProfileOrtu(
    String? nama,
    String? noHp,
    String? alamat,
    String? jenisKelamin,
    String? tipe,
  ) async {
    try {
      bool hasNoChange =
          (nama == ortuDetail.value?.nama &&
          noHp == ortuDetail.value?.nomorHp &&
          alamat == ortuDetail.value?.alamat &&
          jenisKelamin == ortuDetail.value?.jenisKelamin &&
          tipe == ortuDetail.value?.tipe);

      if (hasNoChange) {
        ToastUtils.showErrorToast('Tidak ada perubahan data');
        return;
      }

      isSaveProfileLoading.value = true;

      await _ortuRepository.updateProfile(
        ortuId: ortuId,
        nama: nama ?? ortuDetail.value!.nama!,
        noHp: noHp ?? ortuDetail.value!.nomorHp!,
        alamat: alamat ?? ortuDetail.value!.alamat!,
        jenisKelamin: jenisKelamin ?? ortuDetail.value!.jenisKelamin!,
        tipe: tipe ?? ortuDetail.value!.tipe!,
      );

      await getOrtuDetail(isReload: false);

      if (Get.isRegistered<DaftarOrtuController>()) {
        await Get.find<DaftarOrtuController>().fetchData();
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

  Future<void> updateEmailPasswordOrtu(String? email, String? password) async {
    try {
      bool hasNoChange =
          (email == ortuDetail.value?.user?.email &&
          (password == null || password.isEmpty));

      if (hasNoChange) {
        ToastUtils.showErrorToast('Tidak ada perubahan data');
        return;
      }

      isSaveEmailPasswordLoading.value = true;

      String oldEmail = ortuDetail.value?.user?.email ?? "";
      bool emailChanged = email != oldEmail;
      bool passwordChanged = password != null && password.isNotEmpty;

      await _ortuRepository.updateEmailPassword(
        ortuId: ortuId,
        email: email,
        password: password,
      );

      await getOrtuDetail(isReload: false);
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
