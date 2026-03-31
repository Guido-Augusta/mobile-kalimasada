import 'package:get/get.dart';

import '../controllers/detail_hafalan_surah_controller.dart';

class DetailHafalanSurahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailHafalanSurahController>(
      () => DetailHafalanSurahController(),
    );
  }
}
