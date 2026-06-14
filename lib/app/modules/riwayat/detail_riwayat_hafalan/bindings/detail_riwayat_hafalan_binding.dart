import 'package:get/get.dart';
import '../../../../data/repositories/riwayat_repository.dart';

import '../controllers/detail_riwayat_hafalan_controller.dart';

class DetailRiwayatHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatRepository>(() => RiwayatRepository());
    Get.lazyPut<DetailRiwayatHafalanController>(
      () => DetailRiwayatHafalanController(),
    );
  }
}
