import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/repositories/hafalan_repository.dart';

import '../controllers/summary_hafalan_controller.dart';

class SummaryHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HafalanRepository>(
      () => HafalanRepository(),
    );
    Get.lazyPut<SummaryHafalanController>(
      () => SummaryHafalanController(),
    );
  }
}
