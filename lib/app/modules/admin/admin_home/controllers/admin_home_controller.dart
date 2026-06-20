import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/exceptions/app_exception.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_ustadz.dart'
    as ustadz_model;
import 'package:mobile_kalimasada/app/data/models/daftar_ortu.dart'
    as ortu_model;
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart'
    as santri_model;
import 'package:mobile_kalimasada/app/data/repositories/auth_repository.dart';
import 'package:mobile_kalimasada/app/data/repositories/ortu_repository.dart';
import 'package:mobile_kalimasada/app/data/repositories/santri_repository.dart';
import 'package:mobile_kalimasada/app/data/repositories/ustadz_repository.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';

class AdminHomeController extends GetxController {
  final UstadzRepository _ustadzRepository = UstadzRepository();
  final OrtuRepository _ortuRepository = OrtuRepository();
  final SantriRepository _santriRepository = SantriRepository();
  final AuthRepository _authRepository = AuthRepository();

  var isLoadingLogout = false.obs;
  var isLoadingStats = false.obs;
  var totalUstadz = 0.obs;
  var totalOrtu = 0.obs;
  var totalSantri = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTotals();
  }

  Future<void> fetchTotals() async {
    isLoadingStats.value = true;
    try {
      final results = await Future.wait([
        _ustadzRepository.fetchUstadzList(page: 1, limit: 1),
        _ortuRepository.fetchOrtuList(page: 1, limit: 1),
        _santriRepository.fetchSantriList(page: 1, limit: 1),
      ]);

      final ustadzData = results[0] as ustadz_model.DaftarUstadz;
      final ortuData = results[1] as ortu_model.DaftarOrtu;
      final santriData = results[2] as santri_model.DaftarSantri;

      totalUstadz.value = ustadzData.pagination?.totalData ?? 0;
      totalOrtu.value = ortuData.pagination?.totalData ?? 0;
      totalSantri.value = santriData.pagination?.totalData ?? 0;
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingStats.value = false;
    }
  }

  void logout() async {
    isLoadingLogout.value = true;
    final userId = AuthService.to.userId.value;
    try {
      await _authRepository.logout(userId);
      await AuthService.to.logout();
      Get.offAllNamed('/login');
      ToastUtils.showSuccessToast('Logout berhasil');
    } on AppException catch (e) {
      ToastUtils.showErrorToast(e.message);
    } catch (e) {
      ToastUtils.showErrorToast('Terjadi kesalahan sistem');
    } finally {
      isLoadingLogout.value = false;
    }
  }
}
