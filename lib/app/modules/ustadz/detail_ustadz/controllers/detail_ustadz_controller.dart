import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/utils/image_helper.dart';

import '../../../../data/models/ustadz.dart';
import '../../../../data/repositories/ustadz_repository.dart';
import '../../../../utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/data/constants/app_constants.dart';

class DetailUstadzController extends GetxController {
  final UstadzRepository _ustadzRepository = Get.find<UstadzRepository>();

  final ustadzId = Get.arguments['ustadzId'];
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

  @override
  void onInit() {
    super.onInit();
    getUstadzData();
  }

  Future<void> getUstadzData({bool isRefresh = true}) async {
    try {
      isLoading.value = isRefresh;
      final ustadz = await _ustadzRepository.getUstadz(ustadzId);

      ustadzData.value = ustadz;
      if (ustadz.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = getImageUrl(ustadz.fotoProfil!);
      }
      namaC.text = ustadz.nama!;
      noHpC.text = ustadz.nomorHp!;
      alamatC.text = ustadz.alamat!;
      jenisKelaminC.text = ustadz.jenisKelamin!;
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  String getImageUrl(String imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }
}
