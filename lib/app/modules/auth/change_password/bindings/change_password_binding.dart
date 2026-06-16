import 'package:get/get.dart';
import '../../../../data/repositories/auth_repository.dart';

import '../controllers/change_password_controller.dart';

class ChangePasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<ChangePasswordController>(
      () => ChangePasswordController(),
    );
  }
}
