import 'package:get/get.dart';

import '../controllers/santri_home_controller.dart';

class SantriHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SantriHomeController>(
      () => SantriHomeController(),
    );
  }
}
