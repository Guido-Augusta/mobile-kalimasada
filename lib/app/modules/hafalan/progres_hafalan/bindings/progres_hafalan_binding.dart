import 'package:get/get.dart';

import '../../../../data/repositories/hafalan_repository.dart';
import '../controllers/progres_hafalan_controller.dart';

class ProgresHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HafalanRepository>(() => HafalanRepository());
    Get.lazyPut<ProgresHafalanController>(() => ProgresHafalanController());
  }
}
