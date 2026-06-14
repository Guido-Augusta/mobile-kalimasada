import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../controllers/ortu_main_controller.dart';

class OrtuMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<OrtuRepository>(() => OrtuRepository());
    Get.lazyPut<OrtuMainController>(
      () => OrtuMainController(),
    );
  }
}
