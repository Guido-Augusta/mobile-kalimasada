import 'package:get/get.dart';

import '../../../../data/repositories/hafalan_repository.dart';
import '../../../../data/repositories/quran_repository.dart';
import '../controllers/detail_hafalan_surah_controller.dart';

class DetailHafalanSurahBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HafalanRepository>(() => HafalanRepository());
    Get.lazyPut<QuranRepository>(() => QuranRepository());
    Get.lazyPut<DetailHafalanSurahController>(
      () => DetailHafalanSurahController(),
    );
  }
}
