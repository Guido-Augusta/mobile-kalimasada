import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile_kalimasada/app/utils/image_helper.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/ustadz.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_home/controllers/ustadz_home_controller.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/data/constants/app_constants.dart';

import '../../../../data/exceptions/app_exception.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/ustadz_repository.dart';
import '../../../../routes/app_pages.dart';

class UstadzProfileController extends GetxController {
  final UstadzRepository _ustadzRepository = Get.find<UstadzRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();

  final isLoading = true.obs;
  final isSaveLoading = false.obs;
  final isLoadingLogout = false.obs;
  final isUploadingImage = false.obs;
  var ustadzData = Rxn<Ustadz>();
  var fotoProfil = AppConstants.defaultProfileImageUrl.obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController();
  var imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    getUstadzDetail();
  }

  Future<void> getUstadzDetail() async {
    try {
      isLoading.value = true;
      final ustadzId = AuthService.to.roleId.value;
      final ustadz = await _ustadzRepository.getUstadz(ustadzId);
      ustadzData.value = ustadz;
      if (ustadz.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = ImageHelper.getImageUrl(ustadz.fotoProfil!);
      }
      if (ustadz.nama != null) namaC.text = ustadz.nama!;
      if (ustadz.nomorHp != null) noHpC.text = ustadz.nomorHp!;
      if (ustadz.alamat != null) alamatC.text = ustadz.alamat!;
      if (ustadz.jenisKelamin != null)
        jenisKelaminC.text = ustadz.jenisKelamin!;
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileData(
    String? nama,
    String? noHp,
    String? alamat,
    String? jenisKelamin,
  ) async {
    try {
      isSaveLoading.value = true;
      bool hasNoChange =
          (nama == ustadzData.value?.nama &&
          noHp == ustadzData.value?.nomorHp &&
          alamat == ustadzData.value?.alamat &&
          jenisKelamin == ustadzData.value?.jenisKelamin);
      if (hasNoChange) {
        ToastUtils.showErrorToast('Tidak ada perubahan data');
        return;
      }

      final ustadzId = AuthService.to.roleId.value;

      final currentUser = ustadzData.value?.user;

      final ustadz = await _ustadzRepository.updateProfile(
        ustadzId: ustadzId,
        nama: nama ?? ustadzData.value?.nama ?? '',
        noHp: noHp ?? ustadzData.value?.nomorHp ?? '',
        alamat: alamat ?? ustadzData.value?.alamat ?? '',
        jenisKelamin: jenisKelamin ?? ustadzData.value?.jenisKelamin ?? '',
        waliKelasTahap: ustadzData.value?.waliKelasTahap,
      );

      if (ustadz.user == null && currentUser != null) {
        ustadzData.value = ustadz.copyWith(user: currentUser);
      } else {
        ustadzData.value = ustadz;
      }

      if (ustadzData.value?.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = getImageUrl(ustadzData.value!.fotoProfil!);
      }
      namaC.text = ustadzData.value?.nama ?? '';
      noHpC.text = ustadzData.value?.nomorHp ?? '';
      alamatC.text = ustadzData.value?.alamat ?? '';
      jenisKelaminC.text = ustadzData.value?.jenisKelamin ?? '';

      if (Get.isRegistered<UstadzHomeController>()) {
        Get.find<UstadzHomeController>().getUstadz();
      }
      Get.back();
      ToastUtils.showSuccessToast('Profil berhasil diperbarui');
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isSaveLoading.value = false;
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
      final ustadzId = AuthService.to.roleId.value;

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
      String contentType = (extension == '.png') ? 'image/png' : 'image/jpeg';

      final updatedUstadz = await _ustadzRepository.uploadFotoProfil(
        ustadzId: ustadzId,
        bytes: bytes,
        fileName: finalFileName,
        contentType: contentType,
      );

      ustadzData.value =
          updatedUstadz.user == null && ustadzData.value?.user != null
          ? updatedUstadz.copyWith(user: ustadzData.value?.user)
          : updatedUstadz;

      if (ustadzData.value?.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = getImageUrl(ustadzData.value!.fotoProfil!);
      }

      if (Get.isRegistered<UstadzHomeController>()) {
        Get.find<UstadzHomeController>().getUstadz();
      }

      Get.back();
      ToastUtils.showSuccessToast('Foto profil berhasil diperbarui');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoadingLogout.value = true;
      final userId = AuthService.to.userId.value;

      await _authRepository.logout(userId);
      await AuthService.to.logout();

      Get.offAllNamed(Routes.LOGIN);
      ToastUtils.showSuccessToast('Logout berhasil');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingLogout.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }
}
