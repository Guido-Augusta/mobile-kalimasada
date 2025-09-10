import 'package:get/get.dart';

import '../controllers/ustadz_main_controller.dart';

class UstadzMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UstadzMainController>(
      () => UstadzMainController(),
    );
  }
}
