import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/quran_repository.dart';

import '../controllers/detail_surah_controller.dart';

class DetailSurahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuranRepository>(() => QuranRepository());
    Get.lazyPut<DetailSurahController>(() => DetailSurahController());
  }
}
