import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  RxInt currentIndex = 0.obs;
  final role = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getProfile();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void getProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('role') ?? '';
    this.role.value = role;
  }
}
