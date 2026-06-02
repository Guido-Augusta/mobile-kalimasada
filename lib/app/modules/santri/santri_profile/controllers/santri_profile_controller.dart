import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/data/models/santri.dart';
import 'package:mobile_kalimasada/app/data/repositories/auth_repository.dart';
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';
import 'package:mobile_kalimasada/app/modules/santri/santri_home/controllers/santri_home_controller.dart';
import 'package:mobile_kalimasada/app/utils/image_helper.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:mobile_kalimasada/app/data/constants/app_constants.dart';

enum ChartType { tambahHafalan, murajaah, tahsin }

class SantriProfileController extends GetxController {
  final _authRepository = AuthRepository();
  final _santriRepository = SantriRepository();

  final santriId = AuthService.to.roleId.value;

  final formKey = GlobalKey<FormState>();

  var isLoading = false.obs;
  var isSaveLoading = false.obs;
  var isLoadingLogout = false.obs;
  var santriData = Rxn<Santri>();

  final imagePicker = ImagePicker();
  var isUploadingImage = false.obs;
  var fotoProfil = AppConstants.defaultProfileImageUrl.obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();
  var jenisKelaminC = TextEditingController();
  var tanggalLahirC = TextEditingController();

  var isLoadingChart = false.obs;
  var isChartError = false.obs;
  var chart = Rxn<c.Chart>();
  var range = '1w'.obs;
  var selectedChartType = ChartType.tambahHafalan.obs;
  var selectedChartMode = 'ayat'.obs;

  @override
  void onInit() async {
    super.onInit();
    loadProfileData();
  }

  @override
  void onClose() {
    namaC.dispose();
    noHpC.dispose();
    alamatC.dispose();
    jenisKelaminC.dispose();
    tanggalLahirC.dispose();
    super.onClose();
  }

  String getImageUrl(String? imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> loadProfileData({bool refresh = false}) async {
    try {
      isLoading.value = refresh;
      isLoadingChart.value = refresh;
      await Future.wait([
        _santriRepository.getSantri(santriId).then((data) {
          santriData.value = data;
        }),
        _santriRepository
            .getChart(range.value, santriId, selectedChartMode.value)
            .then((data) {
              chart.value = data;
            }),
      ]);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
      isLoadingChart.value = false;
    }
  }

  Future<void> getSantriDetail() async {
    try {
      isLoading.value = true;
      final santriId = AuthService.to.roleId.value;

      final data = await _santriRepository.getSantri(santriId);
      santriData.value = data;
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileData(String? nama) async {
    try {
      isSaveLoading.value = true;
      bool hasNoChange = (nama == santriData.value?.nama);

      if (hasNoChange) {
        ToastUtils.showErrorToast('Tidak ada perubahan data');
        return;
      }

      final santriId = AuthService.to.roleId.value;

      await _santriRepository.updateNamaSantri(nama, santriId);

      await getSantriDetail();
      if (Get.isRegistered<SantriHomeController>()) {
        Get.find<SantriHomeController>().getSantri();
      }
      Get.back();
      ToastUtils.showSuccessToast('Profil berhasil diperbarui');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  Future<void> getChart() async {
    isLoadingChart.value = true;
    isChartError.value = false;
    try {
      final data = await _santriRepository.getChart(
        range.value,
        santriId,
        selectedChartMode.value,
      );
      chart.value = data;
    } catch (e) {
      isChartError.value = true;
      ToastUtils.showErrorToast(e.toString());
    }
    isLoadingChart.value = false;
  }

  // Format the date to display in the text field
  String formatDate(DateTime date) {
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

  void logout() async {
    try {
      isLoadingLogout.value = true;
      final userId = AuthService.to.userId.value;
      await _authRepository.logout(userId);
      await AuthService.to.logout();
      Get.offAllNamed('/login');
      ToastUtils.showSuccessToast('Logout berhasil');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoadingLogout.value = false;
    }
  }
}
