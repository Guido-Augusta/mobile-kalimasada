import 'package:get/get.dart';

import '../../../../data/repositories/ortu_repository.dart';
import '../controllers/daftar_ortu_controller.dart';

class DaftarOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrtuRepository>(() => OrtuRepository());
    Get.lazyPut<DaftarOrtuController>(
      () => DaftarOrtuController(),
    );
  }
}
