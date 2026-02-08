import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/alquran/controllers/alquran_controller.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/alquran/views/alquran_view.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_home/views/ustadz_home_view.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_home/controllers/ustadz_home_controller.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_profile/views/ustadz_profile_view.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_profile/controllers/ustadz_profile_controller.dart';

import '../controllers/ustadz_main_controller.dart';

class UstadzMainView extends GetView<UstadzMainController> {
  final ustadzHomeC = Get.put(UstadzHomeController());
  final ustadzProfileC = Get.put(UstadzProfileController());
  final alquranC = Get.put(AlquranController());
  UstadzMainView({super.key});
  @override
  Widget build(BuildContext context) {
    // Preload data saat build
    final ustadzHomeController = Get.find<UstadzHomeController>();
    if (ustadzHomeController.ustadz.value == null &&
        !ustadzHomeController.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ustadzHomeController.getUstadz();
      });
    }

    Widget body() {
      switch (controller.currentIndex.value) {
        case 0:
          return const UstadzHomeView();
        case 1:
          return const AlquranView();
        case 2:
          return const UstadzProfileView();
        default:
          return const UstadzHomeView();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final canExit = await controller.onWillPop();
        if (canExit) {
          Get.reset();
          SystemNavigator.pop(); // Exit app
        }
      },
      child: Scaffold(
        body: Obx(() => body()),
        bottomNavigationBar: Obx(
          () => Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedItemColor: Colors.deepPurpleAccent,
              selectedFontSize: 12,
              currentIndex: controller.currentIndex.value,
              onTap: (index) {
                controller.currentIndex.value = index;
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: Colors.grey),
                  activeIcon: Icon(Icons.home, color: Colors.deepPurpleAccent),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book, color: Colors.grey),
                  activeIcon: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.deepPurpleAccent,
                  ),
                  label: 'Al-Qur\'an',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, color: Colors.grey),
                  activeIcon: Icon(
                    Icons.person,
                    color: Colors.deepPurpleAccent,
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
