import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../../../data/constants/app_constants.dart';
import '../../../../data/exceptions/app_exception.dart';
import '../../../../data/models/ortu.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/image_helper.dart';
import '../../../../utils/toast_utils.dart';
import '../../ortu_home/controllers/ortu_home_controller.dart';

class OrtuProfileController extends GetxController {
  final OrtuRepository _ortuRepository = Get.find<OrtuRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isSaveLoading = false.obs;
  var isLoadingLogout = false.obs;
  var ortuDetail = Rxn<Ortu>();

  final imagePicker = ImagePicker();
  var isUploadingImage = false.obs;
  var fotoProfil = AppConstants.defaultProfileImageUrl.obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();

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
    super.onClose();
  }

  String getImageUrl(String? imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> getOrtuDetail({bool isReload = true}) async {
    try {
      isLoading.value = isReload;
      final ortuId = AuthService.to.roleId.value;
      final ortu = await _ortuRepository.getOrtuDetail(ortuId);
      ortuDetail.value = ortu;

      if (ortu.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = ImageHelper.getImageUrl(ortu.fotoProfil);
      }

      // Initialize controllers with current values
      if (isReload && ortu.nama != null) namaC.text = ortu.nama!;
      if (isReload && ortu.nomorHp != null) noHpC.text = ortu.nomorHp!;
      if (isReload && ortu.alamat != null) alamatC.text = ortu.alamat!;
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
      isUploadingImage.value = true;
      final ortuId = AuthService.to.roleId.value;

      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final fileName = path.basename(imagePath);
      final extension = path.extension(imagePath).toLowerCase();

      String finalFileName = fileName;
      if (extension != '.jpg' && extension != '.jpeg' && extension != '.png') {
        finalFileName = '${path.basenameWithoutExtension(imagePath)}.jpg';
      }

      String contentType = (extension == '.png') ? 'image/png' : 'image/jpeg';

      // Cache user object for defensive merge
      final currentUser = ortuDetail.value?.user;

      final updatedOrtu = await _ortuRepository.uploadFotoProfil(
        ortuId: ortuId,
        bytes: bytes,
        fileName: finalFileName,
        contentType: contentType,
      );

      // Preserve user relation
      if (updatedOrtu.user == null && currentUser != null) {
        ortuDetail.value = updatedOrtu.copyWith(user: currentUser);
      } else {
        ortuDetail.value = updatedOrtu;
      }

      if (updatedOrtu.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = ImageHelper.getImageUrl(updatedOrtu.fotoProfil);
      }

      if (Get.isRegistered<OrtuHomeController>()) {
        Get.find<OrtuHomeController>().loadHomeData(isRefresh: true);
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

  Future<void> updateProfileData(
    String? nama,
    String? noHp,
    String? alamat,
  ) async {
    try {
      bool hasNoChange =
          (nama == ortuDetail.value?.nama &&
          noHp == ortuDetail.value?.nomorHp &&
          alamat == ortuDetail.value?.alamat);

      if (hasNoChange) {
        ToastUtils.showErrorToast('Tidak ada perubahan data');
        return;
      }

      isSaveLoading.value = true;
      final ortuId = AuthService.to.roleId.value;

      final existingJenisKelamin = ortuDetail.value?.jenisKelamin ?? 'L';
      final existingTipe = ortuDetail.value?.tipe ?? 'Ayah';

      final currentUser = ortuDetail.value?.user;

      final updatedOrtu = await _ortuRepository.updateProfile(
        ortuId: ortuId,
        nama: nama ?? ortuDetail.value?.nama ?? '',
        noHp: noHp ?? ortuDetail.value?.nomorHp ?? '',
        alamat: alamat ?? ortuDetail.value?.alamat ?? '',
        jenisKelamin: existingJenisKelamin,
        tipe: existingTipe,
      );

      if (updatedOrtu.user == null && currentUser != null) {
        ortuDetail.value = updatedOrtu.copyWith(user: currentUser);
      } else {
        ortuDetail.value = updatedOrtu;
      }

      if (updatedOrtu.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = ImageHelper.getImageUrl(updatedOrtu.fotoProfil);
      }

      if (Get.isRegistered<OrtuHomeController>()) {
        Get.find<OrtuHomeController>().loadHomeData(isRefresh: true);
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

  Future<void> logout() async {
    try {
      isLoadingLogout.value = true;
      final userId = AuthService.to.userId.value;
      await _authRepository.logout(userId);
      await AuthService.to.logout();
      Get.offAllNamed('/login');
      ToastUtils.showSuccessToast('Logout berhasil');
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem saat logout');
    } finally {
      isLoadingLogout.value = false;
    }
  }
}
