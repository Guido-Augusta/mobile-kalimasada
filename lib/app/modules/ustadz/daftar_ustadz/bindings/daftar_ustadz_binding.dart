import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/ustadz_repository.dart';

import '../controllers/daftar_ustadz_controller.dart';

class DaftarUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UstadzRepository>(() => UstadzRepository());
    Get.lazyPut<DaftarUstadzController>(() => DaftarUstadzController());
  }
}
