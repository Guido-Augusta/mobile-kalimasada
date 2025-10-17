import 'package:get/get.dart';

import '../controllers/detail_progres_controller.dart';

class DetailProgresBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailProgresController>(
      () => DetailProgresController(),
    );
  }
}
