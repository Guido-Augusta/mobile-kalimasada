import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/ustadz.dart';
import 'package:mobile_kalimasada/app/utils/image_helper.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/data/constants/app_constants.dart';
import 'package:mobile_kalimasada/app/data/repositories/ustadz_repository.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../routes/app_pages.dart';

class UstadzHomeController extends GetxController {
  final UstadzRepository _ustadzRepository = UstadzRepository();
  final AuthRepository _authRepository = AuthRepository();

  var isLoading = true.obs;
  var isLoadingLogout = false.obs;
  var ustadz = Rxn<Ustadz>();
  var fotoProfil = AppConstants.defaultProfileImageUrl.obs;

  @override
  void onInit() {
    super.onInit();
    getUstadz();
  }

  String getImageUrl(String imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> getUstadz() async {
    try {
      isLoading.value = true;
      final ustadzId = AuthService.to.roleId.value;

      final data = await _ustadzRepository.getUstadz(ustadzId);

      ustadz.value = data;
      if (ustadz.value?.fotoProfil?.isNotEmpty == true) {
        fotoProfil.value = getImageUrl(ustadz.value!.fotoProfil!);
      }
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
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
}
