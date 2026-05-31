import 'package:get/get.dart';

import '../controllers/peringkat_controller.dart';

class PeringkatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PeringkatController>(
      () => PeringkatController(),
    );
  }
}
