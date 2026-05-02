import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';

class AdminMainController extends GetxController {
  final currentIndex = 0.obs;

  DateTime? lastBackPressTime;

  Future<bool> onWillPop() async {
    final currentTime = DateTime.now();

    // Jika di halaman home dan bukan back pertama
    if (currentIndex.value == 0) {
      if (lastBackPressTime == null ||
          currentTime.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
        lastBackPressTime = currentTime;
        ToastUtils.showErrorToast('Tekan sekali lagi untuk keluar');
        return false; // Prevent exit
      }
      return true; // Allow exit
    }

    // Jika bukan di halaman home, navigasi ke home
    currentIndex.value = 0;
    return false; // Prevent exit
  }
}
