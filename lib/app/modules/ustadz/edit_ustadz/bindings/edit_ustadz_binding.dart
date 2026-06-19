import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/ustadz_repository.dart';

import '../controllers/edit_ustadz_controller.dart';

class EditUstadzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UstadzRepository>(() => UstadzRepository());
    Get.lazyPut<EditUstadzController>(() => EditUstadzController());
  }
}
