import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/controllers/ortu_home_controller.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:path/path.dart' as path;
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/data/constants/app_constants.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../../../../utils/image_helper.dart';

class OrtuProfileController extends GetxController {
  final OrtuRepository _ortuRepository = OrtuRepository();
  final AuthRepository _authRepository = AuthRepository();

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

  DateTime? _lastNoChangeShown;
  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getOrtuDetail();
  }

  String getImageUrl(String? imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> getOrtuDetail() async {
    try {
      isLoading.value = true;
      final ortuId = AuthService.to.roleId.value;
      final ortu = await _ortuRepository.getOrtuDetail(ortuId);
      ortuDetail.value = ortu;
      if (ortu.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = ImageHelper.getImageUrl(ortu.fotoProfil);
      }
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(e.toString());
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

  Future<void> uploadImage(String imagePath) async {
    try {
      isUploadingImage.value = true;
      final ortuId = AuthService.to.roleId.value;

      // Persiapkan parameter file
      final file = File(imagePath);
      final bytes = await file.readAsBytes();
      final fileName = path.basename(imagePath);
      final extension = path.extension(imagePath).toLowerCase();

      // Pastikan ekstensi gambar valid
      String finalFileName = fileName;
      if (extension != '.jpg' && extension != '.jpeg' && extension != '.png') {
        finalFileName = '${path.basenameWithoutExtension(imagePath)}.jpg';
      }

      // Tentukan tipe konten
      String contentType = (extension == '.png') ? 'image/png' : 'image/jpeg';

      final updatedOrtu = await _ortuRepository.uploadFotoProfil(
        ortuId: ortuId,
        bytes: bytes,
        fileName: finalFileName,
        contentType: contentType,
      );

      if (updatedOrtu.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = ImageHelper.getImageUrl(updatedOrtu.fotoProfil);
      }

      // Refresh Home Screen jika terbuka
      if (Get.isRegistered<OrtuHomeController>()) {
        Get.find<OrtuHomeController>().loadHomeData(isRefresh: true);
      }

      Get.back();
      ToastUtils.showSuccessToast('Foto profil berhasil diperbarui');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
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
      isSaveLoading.value = true;

      // Cek apakah ada perubahan
      bool hasNoChange =
          (nama == ortuDetail.value?.nama &&
          noHp == ortuDetail.value?.nomorHp &&
          alamat == ortuDetail.value?.alamat);

      if (hasNoChange) {
        final now = DateTime.now();
        if (_lastNoChangeShown == null ||
            now.difference(_lastNoChangeShown!) > const Duration(seconds: 3)) {
          _lastNoChangeShown = now;
          ToastUtils.showErrorToast('Tidak ada perubahan data');
        }
        return;
      }

      final ortuId = AuthService.to.roleId.value;
      final updatedOrtu = await _ortuRepository.updateProfile(
        ortuId: ortuId,
        nama: nama ?? ortuDetail.value?.nama ?? '',
        noHp: noHp ?? ortuDetail.value?.nomorHp ?? '',
        alamat: alamat ?? ortuDetail.value?.alamat ?? '',
      );

      ortuDetail.value = updatedOrtu;
      if (updatedOrtu.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = ImageHelper.getImageUrl(updatedOrtu.fotoProfil);
      }

      // Refresh Home Screen jika terbuka
      if (Get.isRegistered<OrtuHomeController>()) {
        Get.find<OrtuHomeController>().loadHomeData(isRefresh: true);
      }

      Get.back();
      ToastUtils.showSuccessToast('Profil berhasil diperbarui');
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(e.toString());
      }
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
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(e.toString());
      }
    } finally {
      isLoadingLogout.value = false;
    }
  }
}
