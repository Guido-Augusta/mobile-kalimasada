import 'package:get/get.dart';

import '../controllers/edit_ustadz_controller.dart';

class EditUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditUstadzController>(
      () => EditUstadzController(),
    );
  }
}
