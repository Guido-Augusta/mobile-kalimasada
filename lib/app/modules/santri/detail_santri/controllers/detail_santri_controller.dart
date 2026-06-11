import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';
import 'package:mobile_kalimasada/app/modules/santri/daftar_santri/controllers/daftar_santri_controller.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../services/auth_service.dart';
import '../../../../utils/image_helper.dart';

enum ChartType { tambahHafalan, murajaah, tahsin }

class DetailSantriController extends GetxController {
  final _santriRepository = Get.find<SantriRepository>();

  String token = AuthService.to.token.value;
  Rx<UserRole> userRole = AuthService.to.currentRole;

  // Helper methods
  bool get isAdmin => userRole.value == UserRole.admin;
  bool get isUstadz => userRole.value == UserRole.ustadz;
  bool get isSantri => userRole.value == UserRole.santri;
  bool get isOrtu => userRole.value == UserRole.ortu;

  var isLoading = false.obs;
  var isSaveLoading = false.obs;
  var santriData = Rxn<s.Santri>();
  var santriId = Get.arguments;

  var selectedTahap = ''.obs;

  var isLoadingChart = false.obs;
  var isChartError = false.obs;
  var chart = Rxn<c.Chart>();
  var range = '1w'.obs;
  var selectedChartType = ChartType.tambahHafalan.obs;
  var selectedChartMode = 'ayat'.obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData({bool refresh = true}) async {
    try {
      isLoading.value = refresh;
      isLoadingChart.value = refresh;
      await Future.wait([
        _santriRepository.getSantri(santriId).then((data) {
          santriData.value = data;
          selectedTahap.value = data.tahapHafalan ?? '';
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

  Future<void> getSantriDetail(String santriId, {bool isRefresh = true}) async {
    try {
      isLoading.value = isRefresh;

      final data = await _santriRepository.getSantri(santriId);

      santriData.value = data;
      selectedTahap.value = data.tahapHafalan ?? '';
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void updateTahapHafalan(String tahapHafalan) async {
    if (tahapHafalan == santriData.value?.tahapHafalan) {
      ToastUtils.showErrorToast('Tidak ada perubahan data');
      return;
    }
    isSaveLoading.value = true;
    try {
      await _santriRepository.updateTahapHafalan(tahapHafalan, santriId);
      await getSantriDetail(santriId);
      if (Get.isRegistered<DaftarSantriController>()) {
        await Get.find<DaftarSantriController>().getSantriList();
      }
      Get.back();
      ToastUtils.showSuccessToast('Tahap hafalan berhasil diperbarui');
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isSaveLoading.value = false;
    }
  }

  void getChart() async {
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

  String getImageUrl(String imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }
}
