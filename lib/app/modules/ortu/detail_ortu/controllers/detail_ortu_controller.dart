import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/models/daftar_santri.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../../../../services/auth_service.dart';
import '../../../../utils/image_helper.dart';
import 'package:mobile_kalimasada/app/data/constants/app_constants.dart';

class DetailOrtuController extends GetxController {
  final OrtuRepository _ortuRepository = Get.find<OrtuRepository>();

  var isLoading = false.obs;
  var isLoadingSantriList = false.obs;
  var isSaveLoading = false.obs;
  var ortuDetail = Rxn<Ortu>();
  var santriList = <Datum>[].obs;

  var ortuId = Get.arguments['ortuId'];

  final imagePicker = ImagePicker();
  var isUploadingImage = false.obs;
  var fotoProfil = AppConstants.defaultProfileImageUrl.obs;

  var namaC = TextEditingController();
  var noHpC = TextEditingController();
  var alamatC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (ortuId != null) {
      loadData(isRefresh: true);
    }
  }

  String getImageUrl(String? imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> loadData({bool isRefresh = false}) async {
    if (isLoading.value || isLoadingSantriList.value) {
      return;
    }

    try {
      isLoading.value = isRefresh;
      isLoadingSantriList.value = true;

      final id = ortuId!.toString();

      await Future.wait([
        _ortuRepository.getOrtuDetail(id).then((ortu) {
          ortuDetail.value = ortu;
          if (ortu.fotoProfil?.isNotEmpty == true) {
            fotoProfil.value = ImageHelper.getImageUrl(ortu.fotoProfil);
          }
          if (kDebugMode) {
            print('Ortu detail loaded: ${ortu.nama}');
          }
        }),
        if (AuthService.to.isAdmin)
          _ortuRepository.getSantriList(id).then((items) {
            santriList.assignAll(items);
            if (kDebugMode) {
              print('Santri list loaded: ${items.length} anak');
            }
          }),
      ]);
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
      isLoadingSantriList.value = false;
    }
  }
}
