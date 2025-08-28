import 'package:get/get.dart';

import '../controllers/ustadz_home_controller.dart';

class UstadzHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UstadzHomeController>(
      () => UstadzHomeController(),
    );
  }
}
