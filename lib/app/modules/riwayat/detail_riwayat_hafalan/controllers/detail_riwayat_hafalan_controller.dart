import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/detail_riwayat_ayat.dart';
import 'package:mobile_kalimasada/app/data/models/detail_riwayat_halaman.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

import '../../../../data/repositories/riwayat_repository.dart';

class DetailRiwayatHafalanController extends GetxController {
  final RiwayatRepository _riwayatRepository = Get.find<RiwayatRepository>();

  final isLoading = false.obs;

  final santriId = Get.arguments['santriId'];
  final tanggalRiwayat = Get.arguments['tanggalRiwayat'];
  final status = Get.arguments['status'];

  final surahId = Get.arguments['surahId'];
  final juzId = Get.arguments['juzId'];

  bool get isAyatMode => surahId != null;

  var detailRiwayatAyat = Rxn<DetailRiwayatAyat>();
  var detailRiwayatHalaman = Rxn<DetailRiwayatHalaman>();

  @override
  void onInit() {
    super.onInit();
    getDetailRiwayatHafalan();
  }

  void getDetailRiwayatHafalan() async {
    try {
      isLoading.value = true;

      final santriIdStr = santriId?.toString() ?? '';
      final tanggalRiwayatStr = tanggalRiwayat?.toString().split(' ')[0] ?? '';
      final statusStr = status?.toString() ?? '';

      if (santriIdStr.isEmpty ||
          tanggalRiwayatStr.isEmpty ||
          statusStr.isEmpty) {
        ToastUtils.showErrorToast('Data tidak lengkap');
        return;
      }

      if (isAyatMode) {
        final surahIdStr = surahId?.toString() ?? '';
        final detail = await _riwayatRepository.getDetailRiwayatAyat(
          santriId: santriIdStr,
          tanggal: tanggalRiwayatStr,
          status: statusStr,
          surahId: surahIdStr,
        );
        detailRiwayatAyat.value = detail;
      } else {
        final jIdStr = juzId?.toString() ?? '';
        final detail = await _riwayatRepository.getDetailRiwayatHalaman(
          santriId: santriIdStr,
          tanggal: tanggalRiwayatStr,
          status: statusStr,
          juzId: jIdStr,
        );
        detailRiwayatHalaman.value = detail;
      }
    } catch (e) {
      ToastUtils.showErrorToast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
