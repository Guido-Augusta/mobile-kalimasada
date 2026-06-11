import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/data/repositories/auth_repository.dart';
import 'package:mobile_kalimasada/app/routes/app_pages.dart';
import 'package:mobile_kalimasada/app/utils/image_helper.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';

class SantriHomeController extends GetxController {
  final SantriRepository _santriRepository = Get.find<SantriRepository>();
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  var isLoading = true.obs;
  var isLoadingLogout = false.obs;

  var santri = Rxn<s.Santri>();

  @override
  void onInit() {
    super.onInit();
    getSantri();
  }

  String getImageUrl(String? imageUrl) {
    return ImageHelper.getImageUrl(imageUrl);
  }

  Future<void> getSantri() async {
    try {
      isLoading.value = true;
      final santriId = AuthService.to.roleId.value;
      final data = await _santriRepository.getSantri(santriId);
      santri.value = data;
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
