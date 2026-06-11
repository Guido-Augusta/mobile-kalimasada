import 'package:get/get.dart';

import '../../../../data/repositories/santri_repository.dart';
import '../controllers/peringkat_controller.dart';

class PeringkatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SantriRepository>(() => SantriRepository());
    Get.lazyPut<PeringkatController>(() => PeringkatController());
  }
}
