import 'package:get/get.dart';

import '../controllers/detail_hafalan_juz_controller.dart';

class DetailHafalanJuzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailHafalanJuzController>(
      () => DetailHafalanJuzController(),
    );
  }
}
