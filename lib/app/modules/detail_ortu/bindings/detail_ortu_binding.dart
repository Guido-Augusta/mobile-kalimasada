import 'package:get/get.dart';

import '../controllers/detail_ortu_controller.dart';

class DetailOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailOrtuController>(
      () => DetailOrtuController(),
    );
  }
}
