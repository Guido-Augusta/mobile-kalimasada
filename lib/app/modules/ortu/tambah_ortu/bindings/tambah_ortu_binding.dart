import 'package:get/get.dart';

import '../../../../data/repositories/ortu_repository.dart';
import '../controllers/tambah_ortu_controller.dart';

class TambahOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrtuRepository>(() => OrtuRepository());
    Get.lazyPut<TambahOrtuController>(
      () => TambahOrtuController(),
    );
  }
}
