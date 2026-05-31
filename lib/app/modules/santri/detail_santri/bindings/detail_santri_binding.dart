import 'package:get/get.dart';

import '../controllers/detail_santri_controller.dart';

class DetailSantriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailSantriController>(
      () => DetailSantriController(),
    );
  }
}
