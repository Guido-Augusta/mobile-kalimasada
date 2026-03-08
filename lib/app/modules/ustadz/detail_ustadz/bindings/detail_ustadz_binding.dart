import 'package:get/get.dart';

import '../controllers/detail_ustadz_controller.dart';

class DetailUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailUstadzController>(
      () => DetailUstadzController(),
    );
  }
}
