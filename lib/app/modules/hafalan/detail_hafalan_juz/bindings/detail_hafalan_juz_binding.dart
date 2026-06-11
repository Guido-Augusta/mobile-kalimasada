import 'package:get/get.dart';

import '../../../../data/repositories/hafalan_repository.dart';
import '../controllers/detail_hafalan_juz_controller.dart';

class DetailHafalanJuzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HafalanRepository>(() => HafalanRepository());
    Get.lazyPut<DetailHafalanJuzController>(() => DetailHafalanJuzController());
  }
}
