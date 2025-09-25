import 'package:get/get.dart';

import '../controllers/alquran_controller.dart';

class AlquranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AlquranController>(() => AlquranController());
  }
}
