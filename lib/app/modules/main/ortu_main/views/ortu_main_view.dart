import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/views/ortu_home_view.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/controllers/ortu_home_controller.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_profile/controllers/ortu_profile_controller.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_profile/views/ortu_profile_view.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/alquran/controllers/alquran_controller.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/alquran/views/alquran_view.dart';

import '../controllers/ortu_main_controller.dart';

class OrtuMainView extends GetView<OrtuMainController> {
  final ortuHomeC = Get.put(OrtuHomeController());
  final alquranC = Get.put(AlquranController());
  final ortuProfileC = Get.put(OrtuProfileController());
  OrtuMainView({super.key});
  @override
  Widget build(BuildContext context) {
    // Preload data saat build
    final ortuHomeController = Get.find<OrtuHomeController>();
    if (ortuHomeController.ortu.value == null &&
        !ortuHomeController.isLoading.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ortuHomeController.getOrtu();
      });
    }

    Widget body() {
      switch (controller.currentIndex.value) {
        case 0:
          return const OrtuHomeView();
        case 1:
          return const AlquranView();
        case 2:
          return const OrtuProfileView();
        default:
          return const OrtuHomeView();
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
