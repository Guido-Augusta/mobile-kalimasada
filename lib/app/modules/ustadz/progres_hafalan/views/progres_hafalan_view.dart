import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/progres_hafalan.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/progres_hafalan_controller.dart';

class ProgresHafalanView extends GetView<ProgresHafalanController> {
  const ProgresHafalanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Progres Hafalan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Obx(() {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: controller.isFabVisible.value
              ? Offset.zero
              : const Offset(2, 0), // geser ke kanan
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'scroll_up',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                onPressed: () {
                  controller.scrollC.animateTo(
                    0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.fastLinearToSlowEaseIn,
                  );
                },
                child: const Icon(
                  Icons.keyboard_arrow_up_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'scroll_down',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                onPressed: () {
                  controller.scrollC.animateTo(
                    controller.scrollC.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.fastLinearToSlowEaseIn,
                  );
                },
                child: const Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height:
                    (MediaQuery.of(Get.context!).size.height -
                        MediaQuery.of(Get.context!).padding.top -
                        AppBar().preferredSize.height) *
                    0.05,
              ),
            ],
          ),
        );
      }),

      body: RefreshIndicator(
        onRefresh: () async {
          await controller.getProgresHafalan(controller.santriId);
        },
        child: Obx(() {
          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (controller.isFabVisible.value) {
                  controller.isFabVisible.value = false;
                }
              } else if (notification.direction == ScrollDirection.forward) {
                if (!controller.isFabVisible.value) {
                  controller.isFabVisible.value = true;
                }
              }
              return true;
            },
            child: CustomScrollView(
              controller: controller.scrollC,
              slivers: [
                // Student Info Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: buildSantriInfoCard(),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: buildSearchBar(),
                  ),
                ),

                // Progress Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    child: buildProgressHeader(),
                  ),
                ),

                // Surah Progress List
                if (controller.isLoading.value)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Memuat data...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (controller.progresHafalan.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.book_outlined,
                              size: 48,
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada data',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tarik ke bawah untuk refresh',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (controller.searchQuery.value.isNotEmpty &&
                    controller.filteredSurahList.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'Tidak ada hasil pencarian',
                        style: TextStyle(color: Colors.grey[600], fontSize: 16),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Check if this is the last item (doa khatam card)
                          final surahList = controller.searchQuery.value.isEmpty
                              ? controller.progresHafalan
                              : controller.filteredSurahList;

                          if (index == surahList.length) {
                            // Return doa khatam card as the last item
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildDoaKhatamCard(),
                            );
                          }

                          // Return surah progress card
                          final surah = surahList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildSurahProgressCard(surah, index),
                          );
                        },
                        childCount:
                            (controller.searchQuery.value.isEmpty
                                ? controller.progresHafalan.length
                                : controller.filteredSurahList.length) +
                            1, // Add 1 for the doa khatam card
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Container buildSantriInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B46C1).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama Santri
                    Skeletonizer(
                      enabled:
                          controller.isLoading.value ||
                          controller.santriData.value == null,
                      effect: ShimmerEffect(
                        baseColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.4),
                      ),
                      child: controller.isLoading.value
                          ? Text(
                              'Nama Lengkap Santri',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                            )
                          : Text(
                              controller.santriData.value?.nama ??
                                  'Nama Lengkap Santri',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),

                    // No Induk
                    Skeletonizer(
                      enabled:
                          controller.isLoading.value ||
                          controller.santriData.value == null,
                      effect: ShimmerEffect(
                        baseColor: Colors.white.withValues(alpha: 0.2),
                        highlightColor: Colors.white.withValues(alpha: 0.4),
                      ),
                      child: controller.isLoading.value
                          ? Text(
                              'Nomor Induk',
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            )
                          : Text(
                              controller.santriData.value?.noInduk ??
                                  'Nomor Induk',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoCard(
                'Total Poin',
                '${controller.santriData.value?.totalPoin ?? 'Poin'}',
              ),
              const SizedBox(width: 12),
              _buildInfoCard(
                'Tahap Hafalan',
                getTahapanLabel(
                  controller.santriData.value?.tahapHafalan ?? '-',
                ),
                flex: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(
        () => TextField(
          controller: controller.searchController,
          onChanged: (value) {
            controller.searchQuery.value = value;
            controller.searchSurah(value);
          },
          decoration: InputDecoration(
            hintText: 'Cari surah...',
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            suffixIcon: controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.searchQuery.value = '';
                      controller.searchController.clear();
                    },
                  )
                : const SizedBox.shrink(),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
          ),
        ),
      ),
    );
  }

  String getTahapanLabel(String tahapan) {
    switch (tahapan.toLowerCase()) {
      case 'level1':
        return 'Level 1 - Juz 30';
      case 'level2':
        return 'Level 2 - Surah Pilihan';
      case 'level3':
        return 'Level 3 - Juz 1-29';
      default:
        return 'Tahap Hafalan';
    }
  }

  Widget _buildInfoCard(String title, String value, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Skeletonizer(
              enabled:
                  controller.isLoading.value ||
                  controller.santriData.value == null,
              effect: ShimmerEffect(
                baseColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.4),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Skeletonizer(
              enabled:
                  controller.isLoading.value ||
                  controller.santriData.value == null,
              effect: ShimmerEffect(
                baseColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.4),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Row buildProgressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Progres Hafalan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple[800],
          ),
        ),
        Obx(
          () => controller.searchQuery.value.isNotEmpty
              ? Text(
                  '${controller.filteredSurahList.length} surah ditemukan',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSurahProgressCard(Datum surah, int index) {
    // Parse progress string to get current and total ayat
    final progressParts = surah.progress?.split('/') ?? ['0', '0'];
    final currentAyat = int.tryParse(progressParts[0]) ?? 0;
    final totalAyat = surah.totalAyat ?? int.tryParse(progressParts[1]) ?? 0;
    final progressPercentage = totalAyat > 0 ? (currentAyat / totalAyat) : 0.0;

    return InkWell(
      onTap: () {
        Get.toNamed(
          '/detail-progres',
          arguments: {
            'santriId': controller.santriData.value?.id,
            'surahId': surah.id,
          },
        );
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 0.5,
              offset: const Offset(0, 2),
              spreadRadius: 0.5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${surah.nomor}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent[700],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      surah.namaLatin ?? '-',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Label progres surah
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: currentAyat == 0
                          ? Colors.red[50]
                          : currentAyat >= totalAyat
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: currentAyat == 0
                            ? Colors.red[100]!
                            : currentAyat >= totalAyat
                            ? Colors.green[100]!
                            : Colors.orange[100]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      currentAyat == 0
                          ? 'Belum Mulai'
                          : currentAyat >= totalAyat
                          ? 'Hafal'
                          : 'Proses',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: currentAyat == 0
                            ? Colors.red[700]
                            : currentAyat >= totalAyat
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Progress Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progres Ayat',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  '$currentAyat / $totalAyat',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Progress Bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: LinearProgressIndicator(
                value: progressPercentage,
                backgroundColor: Colors.grey[200],
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoaKhatamCard() {
    return FutureBuilder<String?>(
      future: AuthService.getCurrentRole(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == 'santri') {
          return InkWell(
            onTap: () {
              // Navigate to doa khatam page or show dialog
              Get.toNamed('/doa-khatam');
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurple[700]!, Colors.deepPurpleAccent],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 0.5,
                    offset: const Offset(0, 2),
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Doa Khatam Al-Qur\'an',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Doa setelah menyelesaikan pembacaan Al-Qur\'an',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        // Jika bukan santri, jangan tampilkan apa-apa
        return const SizedBox.shrink();
      },
    );
  }
}
