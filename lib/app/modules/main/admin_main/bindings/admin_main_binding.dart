import 'package:get/get.dart';

import '../../../../data/repositories/quran_repository.dart';
import '../../../../data/repositories/santri_repository.dart';
import '../controllers/admin_main_controller.dart';

class AdminMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SantriRepository>(() => SantriRepository());
    Get.lazyPut<QuranRepository>(() => QuranRepository());
    Get.lazyPut<AdminMainController>(() => AdminMainController());
  }
}
