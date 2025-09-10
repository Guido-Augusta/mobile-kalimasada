import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/modules/santri/santri_home/views/santri_home_view.dart';
import 'package:mobile_kalimasada/app/modules/santri/santri_home/controllers/santri_home_controller.dart';

import '../controllers/santri_main_controller.dart';

class SantriMainView extends GetView<SantriMainController> {
  final santriHomeC = Get.put(SantriHomeController());
  SantriMainView({super.key});
  @override
  Widget build(BuildContext context) {
    Widget body() {
      switch (controller.currentIndex.value) {
        case 0:
          return const SantriHomeView();
        case 1:
          return const SantriHomeView();
        case 2:
          return const SantriHomeView();
        default:
          return const SantriHomeView();
      }
    }

    return Scaffold(
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
                icon: Icon(Icons.history, color: Colors.grey),
                activeIcon: Icon(Icons.history, color: Colors.deepPurpleAccent),
                label: 'Riwayat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person, color: Colors.grey),
                activeIcon: Icon(Icons.person, color: Colors.deepPurpleAccent),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
