import 'package:get/get.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../data/repositories/quran_repository.dart';
import '../../../../data/repositories/ustadz_repository.dart';
import '../controllers/ustadz_main_controller.dart';

class UstadzMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthRepository>(() => AuthRepository());
    Get.lazyPut<UstadzRepository>(() => UstadzRepository());
    Get.lazyPut<QuranRepository>(() => QuranRepository());
    Get.lazyPut<UstadzMainController>(() => UstadzMainController());
  }
}
