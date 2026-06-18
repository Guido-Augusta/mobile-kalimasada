import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/quran_repository.dart';

import '../controllers/alquran_controller.dart';

class AlquranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QuranRepository>(() => QuranRepository());
    Get.lazyPut<AlquranController>(() => AlquranController());
  }
}
