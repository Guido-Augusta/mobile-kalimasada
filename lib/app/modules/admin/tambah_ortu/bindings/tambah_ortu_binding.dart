import 'package:get/get.dart';

import '../controllers/tambah_ortu_controller.dart';

class TambahOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahOrtuController>(
      () => TambahOrtuController(),
    );
  }
}
