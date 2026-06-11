import 'package:get/get.dart';

import '../../../../data/repositories/santri_repository.dart';
import '../controllers/detail_santri_controller.dart';

class DetailSantriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SantriRepository>(() => SantriRepository());
    Get.lazyPut<DetailSantriController>(() => DetailSantriController());
  }
}
