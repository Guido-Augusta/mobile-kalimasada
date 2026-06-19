import 'package:get/get.dart';

import '../controllers/tambah_santri_controller.dart';

class TambahSantriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahSantriController>(
      () => TambahSantriController(),
    );
  }
}
