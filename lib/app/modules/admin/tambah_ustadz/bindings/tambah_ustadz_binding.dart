import 'package:get/get.dart';

import '../controllers/tambah_ustadz_controller.dart';

class TambahUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TambahUstadzController>(
      () => TambahUstadzController(),
    );
  }
}
