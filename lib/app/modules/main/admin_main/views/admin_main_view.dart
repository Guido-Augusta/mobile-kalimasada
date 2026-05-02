import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/modules/admin/admin_home/controllers/admin_home_controller.dart';
import 'package:mobile_kalimasada/app/modules/admin/admin_home/views/admin_home_view.dart';
import 'package:mobile_kalimasada/app/modules/quran/alquran/controllers/alquran_controller.dart';
import 'package:mobile_kalimasada/app/modules/quran/alquran/views/alquran_view.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/peringkat/controllers/peringkat_controller.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/peringkat/views/peringkat_view.dart';

import '../controllers/admin_main_controller.dart';

class AdminMainView extends GetView<AdminMainController> {
  final adminHomeC = Get.put(AdminHomeController());
  final alquranC = Get.put(AlquranController());
  final peringkatC = Get.put(PeringkatController());

  AdminMainView({super.key});

  @override
  Widget build(BuildContext context) {
    Widget body() {
      switch (controller.currentIndex.value) {
        case 0:
          return const AdminHomeView();
        case 1:
          return const AlquranView();
        case 2:
          return const PeringkatView();
        default:
          return const AdminHomeView();
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
              unselectedItemColor: Colors.grey,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              currentIndex: controller.currentIndex.value,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                controller.currentIndex.value = index;
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.book_outlined),
                  activeIcon: Icon(Icons.menu_book_rounded),
                  label: 'Al-Qur\'an',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.leaderboard_outlined),
                  activeIcon: Icon(Icons.leaderboard_rounded),
                  label: 'Peringkat',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
