import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/alquran_controller.dart';

class AlquranView extends GetView<AlquranController> {
  const AlquranView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
        title: const Text(
          'Alquran',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Non-scrollable header section
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: (value) {
                      controller.searchQuery.value = value;
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari surah...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: Obx(() {
                        if (controller.searchQuery.value.isNotEmpty) {
                          return IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              controller.searchQuery.value = '';
                              controller.searchController.clear();
                            },
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Scrollable ListView section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.filteredSurahList.length,
                  itemBuilder: (context, index) {
                    final surah = controller.filteredSurahList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () {},
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Row(
                            children: [
                              // Nomor surah dengan octagon frame
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/octagon_frame.png',
                                    width: 45,
                                    height: 45,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    surah.nomor.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Nama surah Latin dan info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      surah.namaLatin!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      children: [
                                        Text(
                                          surah.tempatTurun!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          ' • ${surah.totalAyat.toString()} Ayat',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Nama surah Arab
                              Text(
                                surah.nama!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
