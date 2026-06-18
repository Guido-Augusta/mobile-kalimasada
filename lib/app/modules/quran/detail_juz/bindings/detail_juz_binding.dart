import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/quran_repository.dart';

import '../controllers/detail_juz_controller.dart';

class DetailJuzBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuranRepository>(() => QuranRepository());
    Get.lazyPut<DetailJuzController>(() => DetailJuzController());
  }
}
