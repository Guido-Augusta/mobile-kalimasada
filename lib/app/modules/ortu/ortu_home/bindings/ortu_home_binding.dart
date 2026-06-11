import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/ortu_repository.dart';
import '../controllers/ortu_home_controller.dart';

class OrtuHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<OrtuRepository>(() => OrtuRepository());
    Get.lazyPut<OrtuHomeController>(() => OrtuHomeController());
  }
}
