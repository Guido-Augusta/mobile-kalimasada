import 'package:get/get.dart';

import '../controllers/daftar_surah_controller.dart';

class DaftarSurahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarSurahController>(
      () => DaftarSurahController(),
    );
  }
}
