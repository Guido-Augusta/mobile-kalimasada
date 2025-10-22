import 'package:get/get.dart';

import '../controllers/summary_hafalan_controller.dart';

class SummaryHafalanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SummaryHafalanController>(
      () => SummaryHafalanController(),
    );
  }
}
