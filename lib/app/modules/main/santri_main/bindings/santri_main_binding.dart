import 'package:get/get.dart';

import '../controllers/santri_main_controller.dart';

class SantriMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SantriMainController>(
      () => SantriMainController(),
    );
  }
}
