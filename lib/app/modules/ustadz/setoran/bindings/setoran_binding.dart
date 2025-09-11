import 'package:get/get.dart';

import '../controllers/setoran_controller.dart';

class SetoranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SetoranController>(
      () => SetoranController(),
    );
  }
}
