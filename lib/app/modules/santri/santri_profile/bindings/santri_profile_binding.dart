import 'package:get/get.dart';

import '../controllers/santri_profile_controller.dart';

class SantriProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SantriProfileController>(
      () => SantriProfileController(),
    );
  }
}
