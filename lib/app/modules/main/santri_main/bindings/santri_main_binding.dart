import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/santri_repository.dart';
import '../controllers/santri_main_controller.dart';

class SantriMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<SantriRepository>(() => SantriRepository());
    Get.lazyPut<SantriMainController>(
      () => SantriMainController(),
    );
  }
}
