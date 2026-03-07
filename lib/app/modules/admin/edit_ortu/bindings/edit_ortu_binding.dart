import 'package:get/get.dart';

import '../controllers/edit_ortu_controller.dart';

class EditOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditOrtuController>(
      () => EditOrtuController(),
    );
  }
}
