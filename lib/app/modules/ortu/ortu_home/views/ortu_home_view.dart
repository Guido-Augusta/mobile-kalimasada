import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/ortu_home_controller.dart';

class OrtuHomeView extends GetView<OrtuHomeController> {
  const OrtuHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UstadzHomeView'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text('User ID : ${controller.userId}')),
            Obx(() => Text('Role : ${controller.role}')),
            Obx(() => Text('Token : ${controller.token}')),

            ElevatedButton(
              onPressed: () {
                controller.logout();
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
