import 'package:get/get.dart';

import '../../../../data/repositories/riwayat_repository.dart';
import '../controllers/riwayat_hafalan_controller.dart';

class RiwayatHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RiwayatRepository>(() => RiwayatRepository());
    Get.lazyPut<RiwayatHafalanController>(() => RiwayatHafalanController());
  }
}
