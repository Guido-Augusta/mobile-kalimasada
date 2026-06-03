import 'package:get/get.dart';

import '../controllers/riwayat_hafalan_controller.dart';

class RiwayatHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatHafalanController>(
      () => RiwayatHafalanController(),
    );
  }
}
