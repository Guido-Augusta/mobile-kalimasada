import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/ortu_repository.dart';

import '../controllers/detail_ortu_controller.dart';

class DetailOrtuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrtuRepository>(() => OrtuRepository());
    Get.lazyPut<DetailOrtuController>(() => DetailOrtuController());
  }
}
