import 'package:get/get.dart';

import '../controllers/progres_hafalan_controller.dart';

class ProgresHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProgresHafalanController>(
      () => ProgresHafalanController(),
    );
  }
}
