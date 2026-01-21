import 'package:get/get.dart';

import '../controllers/doa_khatam_controller.dart';

class DoaKhatamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DoaKhatamController>(
      () => DoaKhatamController(),
    );
  }
}
