import 'package:get/get.dart';

import '../../../../data/repositories/santri_repository.dart';
import '../controllers/daftar_santri_controller.dart';

class DaftarSantriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SantriRepository>(() => SantriRepository());
    Get.lazyPut<DaftarSantriController>(() => DaftarSantriController());
  }
}
