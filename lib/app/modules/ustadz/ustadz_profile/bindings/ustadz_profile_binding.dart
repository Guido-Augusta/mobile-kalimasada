import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/ustadz_repository.dart';
import '../controllers/ustadz_profile_controller.dart';

class UstadzProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<UstadzRepository>(() => UstadzRepository());
    Get.lazyPut<UstadzProfileController>(() => UstadzProfileController());
  }
}
