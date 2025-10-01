import 'package:get/get.dart';

import '../controllers/ortu_main_controller.dart';

class OrtuMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrtuMainController>(
      () => OrtuMainController(),
    );
  }
}
