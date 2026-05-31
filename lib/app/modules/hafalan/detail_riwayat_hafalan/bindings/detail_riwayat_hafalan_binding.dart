import 'package:get/get.dart';

import '../controllers/detail_riwayat_hafalan_controller.dart';

class DetailRiwayatHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailRiwayatHafalanController>(
      () => DetailRiwayatHafalanController(),
    );
  }
}
