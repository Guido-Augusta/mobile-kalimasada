import 'package:get/get.dart';

import '../controllers/edit_santri_controller.dart';

class EditSantriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditSantriController>(
      () => EditSantriController(),
    );
  }
}
