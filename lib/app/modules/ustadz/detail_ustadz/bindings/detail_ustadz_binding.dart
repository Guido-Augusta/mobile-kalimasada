import 'package:get/get.dart';

import '../../../../data/repositories/ustadz_repository.dart';
import '../controllers/detail_ustadz_controller.dart';

class DetailUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UstadzRepository>(() => UstadzRepository());
    Get.lazyPut<DetailUstadzController>(() => DetailUstadzController());
  }
}
