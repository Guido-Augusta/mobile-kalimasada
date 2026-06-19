import 'package:get/get.dart';

import '../../../../data/repositories/ortu_repository.dart';
import '../controllers/edit_ortu_controller.dart';

class EditOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrtuRepository>(() => OrtuRepository());
    Get.lazyPut<EditOrtuController>(
      () => EditOrtuController(),
    );
  }
}
