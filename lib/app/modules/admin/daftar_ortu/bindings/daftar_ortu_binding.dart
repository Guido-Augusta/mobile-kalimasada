import 'package:get/get.dart';

import '../controllers/daftar_ortu_controller.dart';

class DaftarOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarOrtuController>(
      () => DaftarOrtuController(),
    );
  }
}
