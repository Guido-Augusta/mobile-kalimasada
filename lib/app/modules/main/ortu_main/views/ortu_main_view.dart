import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/views/ortu_home_view.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/controllers/ortu_home_controller.dart';

import '../controllers/ortu_main_controller.dart';

class OrtuMainView extends GetView<OrtuMainController> {
  final ortuHomeC = Get.put(OrtuHomeController());
  OrtuMainView({super.key});
  @override
  Widget build(BuildContext context) {
    Widget body() {
      switch (controller.currentIndex.value) {
        case 0:
          return const OrtuHomeView();
        case 1:
          return const OrtuHomeView();
        default:
          return const OrtuHomeView();
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
