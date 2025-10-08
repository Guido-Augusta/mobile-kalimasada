import 'package:get/get.dart';

import '../controllers/ortu_profile_controller.dart';

class OrtuProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrtuProfileController>(
      () => OrtuProfileController(),
    );
  }
}
