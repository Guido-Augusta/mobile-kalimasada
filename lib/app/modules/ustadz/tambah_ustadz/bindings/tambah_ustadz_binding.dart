import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/ustadz_repository.dart';

import '../controllers/tambah_ustadz_controller.dart';

class TambahUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UstadzRepository>(() => UstadzRepository());
    Get.lazyPut<TambahUstadzController>(() => TambahUstadzController());
  }
}
