import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/controllers/ortu_home_controller.dart';
import 'package:mobile_kalimasada/app/modules/ortu/ortu_home/views/ortu_home_view.dart';
import 'package:mobile_kalimasada/app/modules/santri/santri_home/controllers/santri_home_controller.dart';
import 'package:mobile_kalimasada/app/modules/santri/santri_home/views/santri_home_view.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_home/controllers/ustadz_home_controller.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_home/views/ustadz_home_view.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_profile/controllers/ustadz_profile_controller.dart';
import 'package:mobile_kalimasada/app/modules/ustadz/ustadz_profile/views/ustadz_profile_view.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final santriHomeC = Get.put(SantriHomeController());
  final ustadzHomeC = Get.put(UstadzHomeController());
  final ustadzProfileC = Get.put(UstadzProfileController());
  final ortuHomeC = Get.put(OrtuHomeController());

  HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    Widget body() {
      if (controller.role.value == 'santri') {
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
      } else if (controller.role.value == 'ustadz') {
        switch (controller.currentIndex.value) {
          case 0:
            return const UstadzHomeView();
          case 1:
            return const UstadzProfileView();
          default:
            return const UstadzHomeView();
        }
      } else if (controller.role.value == 'ortu') {
        switch (controller.currentIndex.value) {
          case 0:
            return const OrtuHomeView();
          case 1:
            return const OrtuHomeView();
          case 2:
            return const OrtuHomeView();
          default:
            return const OrtuHomeView();
        }
      } else {
        return Center(child: Text('Role tidak ditemukan'));
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
            items: controller.role.value == 'ustadz'
                ? [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home, color: Colors.grey),
                      activeIcon: Icon(
                        Icons.home,
                        color: Colors.deepPurpleAccent,
                      ),
                      label: 'Beranda',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person, color: Colors.grey),
                      activeIcon: Icon(
                        Icons.person,
                        color: Colors.deepPurpleAccent,
                      ),
                      label: 'Profil',
                    ),
                  ]
                : [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home, color: Colors.grey),
                      activeIcon: Icon(
                        Icons.home,
                        color: Colors.deepPurpleAccent,
                      ),
                      label: 'Beranda',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.history, color: Colors.grey),
                      activeIcon: Icon(
                        Icons.history,
                        color: Colors.deepPurpleAccent,
                      ),
                      label: 'Riwayat',
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
    );
  }
}
