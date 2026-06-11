import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/santri_repository.dart';
import '../controllers/santri_home_controller.dart';

class SantriHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<SantriRepository>(() => SantriRepository());
    Get.lazyPut<SantriHomeController>(() => SantriHomeController());
  }
}
