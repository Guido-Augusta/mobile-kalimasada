import 'package:get/get.dart';

import '../controllers/daftar_santri_controller.dart';

class DaftarSantriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarSantriController>(
      () => DaftarSantriController(),
    );
  }
}
