import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/tambah_santri_controller.dart';

class TambahSantriView extends GetView<TambahSantriController> {
  const TambahSantriView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TambahSantriView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'TambahSantriView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
