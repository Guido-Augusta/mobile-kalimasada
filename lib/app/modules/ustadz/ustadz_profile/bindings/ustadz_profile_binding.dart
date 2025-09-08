import 'package:get/get.dart';

import '../controllers/ustadz_profile_controller.dart';

class UstadzProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UstadzProfileController>(
      () => UstadzProfileController(),
    );
  }
}
