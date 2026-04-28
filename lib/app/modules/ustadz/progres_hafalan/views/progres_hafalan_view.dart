import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/progres_hafalan_juz.dart'
    as juz_model;
import 'package:mobile_kalimasada/app/data/models/progres_hafalan_surah.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
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
        title: Text(
          'Progres Hafalan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Obx(() {
        final isSurahMode = controller.filterMode.value == 'surah';
        final isEmpty = isSurahMode
            ? controller.progresHafalanSurah.isEmpty
            : controller.progresHafalanJuz.isEmpty;

        if (controller.isLoading.value || isEmpty) {
          return const SizedBox.shrink();
        }
        return AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: controller.isFabVisible.value
              ? Offset.zero
              : const Offset(2, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: 'scroll_up',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                elevation: 4,
                onPressed: () {
                  controller.scrollC.animateTo(
                    0,
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOutCubic,
                  );
                },
                child: const Icon(
                  Icons.keyboard_arrow_up_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: 'scroll_down',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                elevation: 4,
                onPressed: () {
                  if (controller.filterMode.value == 'surah') {
                    controller.listSurahC.animateToItem(
                      index: () {
                        if (controller.searchQuery.value.isEmpty) {
                          return controller.progresHafalanSurah.length - 1;
                        } else {
                          return controller.filteredSurahList.length - 1;
                        }
                      }(),
                      scrollController: controller.scrollC,
                      alignment: 0,
                      duration: (estimatedDistance) {
                        final ms = (estimatedDistance * 0.1)
                            .clamp(300, 1500)
                            .toInt();
                        return Duration(milliseconds: ms);
                      },
                      curve: (estimatedDistance) => Curves.easeInOutCubic,
                    );
                  } else {
                    controller.listJuzC.animateToItem(
                      index: () {
                        if (controller.searchQuery.value.isEmpty) {
                          return controller.progresHafalanJuz.length - 1;
                        } else {
                          return controller.filteredJuzList.length - 1;
                        }
                      }(),
                      scrollController: controller.scrollC,
                      alignment: 0,
                      duration: (estimatedDistance) {
                        final ms = (estimatedDistance * 0.1)
                            .clamp(300, 1500)
                            .toInt();
                        return Duration(milliseconds: ms);
                      },
                      curve: (estimatedDistance) => Curves.easeInOutCubic,
                    );
                  }
                },
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(
                height:
                    (MediaQuery.of(Get.context!).size.height -
                        MediaQuery.of(Get.context!).padding.top -
                        kToolbarHeight) *
                    0.05,
              ),
            ],
          ),
        );
      }),

      body: RefreshIndicator(
        onRefresh: () async {
          await controller.getProgresHafalanSurah(controller.santriId);
          await controller.getProgresHafalanJuz(controller.santriId);
        },
        backgroundColor: Colors.white,
        color: Colors.deepPurpleAccent,
        child: NotificationListener<UserScrollNotification>(
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
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              // Student Info Card
              Obx(() => _buildHeader()),

              // Search Bar + Toggle (combined)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: _buildSearchAndToggleBar(),
                ),
              ),

              // List (reactive)
              Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.deepPurpleAccent,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Memuat data...',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty data state
                if ((controller.filterMode.value == 'surah' &&
                        controller.progresHafalanSurah.isEmpty) ||
                    (controller.filterMode.value == 'juz' &&
                        controller.progresHafalanJuz.isEmpty)) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.05,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Tidak Ada Data',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tarik ke bawah untuk refresh',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // No search result
                final isSearching = controller.searchQuery.value.isNotEmpty;
                final isNoSearchResult =
                    isSearching &&
                    (controller.filterMode.value == 'surah'
                        ? controller.filteredSurahList.isEmpty
                        : controller.filteredJuzList.isEmpty);

                if (isNoSearchResult) {
                  return _buildNoSearchResult();
                }

                // Surah mode
                if (controller.filterMode.value == 'surah') {
                  final surahList = controller.searchQuery.value.isEmpty
                      ? controller.progresHafalanSurah
                      : controller.filteredSurahList;
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                    sliver: SuperSliverList(
                      listController: controller.listSurahC,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == surahList.length) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildDoaKhatamCard(),
                            );
                          }
                          final surah = surahList[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: RepaintBoundary(
                              child: _buildSurahProgressCard(surah, index),
                            ),
                          );
                        },
                        childCount: surahList.length + 1,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: false,
                      ),
                    ),
                  );
                }

                // Juz mode
                final juzList = controller.searchQuery.value.isEmpty
                    ? controller.progresHafalanJuz
                    : controller.filteredJuzList;
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                  sliver: SuperSliverList(
                    listController: controller.listJuzC,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final juz = juzList[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: RepaintBoundary(
                            child: _buildJuzProgressCard(juz),
                          ),
                        );
                      },
                      childCount: juzList.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Santri Info Card ────────────────────────────────────────────────────────

  // ── Santri Header ───────────────────────────────────────────────────────────

  SliverToBoxAdapter _buildHeader() {
    final bool isLoading =
        controller.isLoading.value || controller.santriData.value == null;
    final santri = controller.santriData.value;

    // Initials from name
    String initials = '?';
    if (santri?.nama != null && santri!.nama!.isNotEmpty) {
      final parts = santri.nama!.trim().split(' ');
      initials = parts.length >= 2
          ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
          : parts[0][0].toUpperCase();
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.45),
              blurRadius: 20,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              right: 60,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar with initials
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.18),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Skeletonizer(
                            enabled: isLoading,
                            effect: ShimmerEffect(
                              baseColor: Colors.white.withValues(alpha: 0.2),
                              highlightColor: Colors.white.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            child: Text(
                              isLoading ? 'SA' : initials,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Santri',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withValues(alpha: 0.65),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Skeletonizer(
                              enabled: isLoading,
                              effect: ShimmerEffect(
                                baseColor: Colors.white.withValues(alpha: 0.2),
                                highlightColor: Colors.white.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              child: Text(
                                santri?.nama ?? 'Nama Santri',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats row with icon chips
                  Row(
                    children: [
                      _buildStatChip(
                        label: 'Total Poin',
                        value: isLoading ? '---' : '${santri?.totalPoin ?? 0}',
                        isLoading: isLoading,
                      ),
                      const SizedBox(width: 10),
                      _buildStatChip(
                        label: 'Tahap Hafalan',
                        value: isLoading
                            ? '-------------'
                            : getTahapanLabel(santri?.tahapHafalan ?? '-'),
                        isLoading: isLoading,
                        expanded: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required String value,
    required bool isLoading,
    bool expanded = false,
  }) {
    Widget chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          Skeletonizer(
            enabled: isLoading,
            effect: ShimmerEffect(
              baseColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.4),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return expanded ? Expanded(child: chip) : chip;
  }

  // ── Search + Toggle Bar (combined) ──────────────────────────────────────────

  Widget _buildSearchAndToggleBar() {
    return Obx(() {
      return Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                onTap: () {
                  controller.isFabVisible.value = false;
                },
                onChanged: (value) {
                  controller.searchQuery.value = value;
                  if (controller.filterMode.value == 'surah') {
                    controller.searchSurah(value);
                  } else {
                    controller.searchJuz(value);
                  }
                },
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: controller.filterMode.value == 'surah'
                      ? 'Cari surah...'
                      : 'Cari juz (1-30)...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.6),
                    size: 22,
                  ),
                  border: InputBorder.none,
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel_rounded,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            controller.searchQuery.value = '';
                            controller.searchController.clear();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Toggle Surah / Juz
          Container(
            height: 52,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFilterChip('Surah', 'surah'),
                _buildFilterChip('Juz', 'juz'),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterChip(String label, String mode) {
    final isActive = controller.filterMode.value == mode;
    return GestureDetector(
      onTap: () => controller.switchFilterMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepPurpleAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : Colors.grey[500],
          ),
        ),
      ),
    );
  }

  // ── Helper ──────────────────────────────────────────────────────────────────

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

  // ── Juz Progress Card (compact) ─────────────────────────────────────────────

  Widget _buildJuzProgressCard(juz_model.Datum juz) {
    final statusLabel = juz.currentAyat == 0
        ? 'Belum Mulai'
        : juz.currentAyat >= juz.maxAyat
        ? 'Hafal'
        : 'Proses';

    final statusColor = juz.currentAyat == 0
        ? Colors.red[400]!
        : juz.currentAyat >= juz.maxAyat
        ? const Color(0xFF10B981)
        : Colors.orange[500]!;

    final statusBg = juz.currentAyat == 0
        ? Colors.red[50]!
        : juz.currentAyat >= juz.maxAyat
        ? Colors.green[50]!
        : Colors.orange[50]!;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.toNamed(
          '/detail-hafalan-juz',
          arguments: {
            'santriId': controller.santriData.value?.id,
            'juzId': juz.juz,
            'santriName': controller.santriData.value?.nama,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withValues(alpha: 0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Number badge
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${juz.juz}',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Juz ${juz.juz}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${juz.currentAyat} dari ${juz.maxAyat} ayat',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Percentage pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                statusLabel == 'Hafal'
                                    ? '✓ Hafal'
                                    : '${juz.percentageString}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: juz.percentage,
                            minHeight: 7,
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Chevron
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[300],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Surah Progress Card (compact) ───────────────────────────────────────────

  Widget _buildSurahProgressCard(Datum surah, int index) {
    final statusLabel = surah.currentAyat == 0
        ? 'Belum Mulai'
        : surah.currentAyat >= surah.maxAyat
        ? 'Hafal'
        : 'Proses';

    final statusColor = surah.currentAyat == 0
        ? Colors.red[400]!
        : surah.currentAyat >= surah.maxAyat
        ? const Color(0xFF10B981)
        : Colors.orange[500]!;

    final statusBg = surah.currentAyat == 0
        ? Colors.red[50]!
        : surah.currentAyat >= surah.maxAyat
        ? Colors.green[50]!
        : Colors.orange[50]!;

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        Get.toNamed(
          '/detail-hafalan-surah',
          arguments: {
            'santriId': controller.santriData.value?.id,
            'surahId': surah.id,
            'santriName': controller.santriData.value?.nama,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withValues(alpha: 0.5)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Number badge
                            Container(
                              width: 40,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${surah.nomor}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    surah.namaLatin ?? '-',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${surah.currentAyat} dari ${surah.maxAyat} ayat',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Percentage pill
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                statusLabel == 'Hafal'
                                    ? '✓ Hafal'
                                    : '${surah.percentageString}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: surah.percentage,
                            minHeight: 7,
                            backgroundColor: statusColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Chevron
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey[300],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Doa Khatam Card ─────────────────────────────────────────────────────────

  Widget _buildDoaKhatamCard() {
    return Obx(() {
      if (controller.currentUserRole.value == 'santri') {
        return GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed('/doa-khatam');
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doa Khatam Al-Qur\'an',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Amalkan doa setelah membaca Al-Qur\'an',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildNoSearchResult() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada hasil pencarian',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba dengan kata kunci lain',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
