import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/santri_repository.dart';
import '../controllers/santri_profile_controller.dart';

class SantriProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<SantriRepository>(() => SantriRepository());
    Get.lazyPut<SantriProfileController>(() => SantriProfileController());
  }
}
