import 'package:get/get.dart';

import '../controllers/ortu_home_controller.dart';

class OrtuHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrtuHomeController>(
      () => OrtuHomeController(),
    );
  }
}
