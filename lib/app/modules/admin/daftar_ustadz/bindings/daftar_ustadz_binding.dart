import 'package:get/get.dart';

import '../controllers/daftar_ustadz_controller.dart';

class DaftarUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarUstadzController>(
      () => DaftarUstadzController(),
    );
  }
}
