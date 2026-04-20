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
        title: const Text(
          'Progres Hafalan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                onPressed: () {
                  controller.scrollC.animateTo(
                    0,
                    duration: const Duration(milliseconds: 800),
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
                      duration: (estimatedDistance) =>
                          const Duration(milliseconds: 1000),
                      curve: (estimatedDistance) =>
                          Curves.fastLinearToSlowEaseIn,
                    );
                  } else {
                    controller.listJuzC.animateToItem(
                      index: 29,
                      scrollController: controller.scrollC,
                      alignment: 0,
                      duration: (estimatedDistance) =>
                          const Duration(milliseconds: 800),
                      curve: (estimatedDistance) =>
                          Curves.fastLinearToSlowEaseIn,
                    );
                  }
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
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
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
                      delegate: SliverChildBuilderDelegate((context, index) {
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
                      }, childCount: surahList.length + 1),
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
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final juz = juzList[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildJuzProgressCard(juz),
                      );
                    }, childCount: juzList.length),
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

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6B46C1).withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Icon(
                      Icons.person_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeletonizer(
                        enabled: isLoading,
                        effect: ShimmerEffect(
                          baseColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.4),
                        ),
                        child: Text(
                          santri?.nama ?? 'Nama Santri',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Skeletonizer(
                        enabled: isLoading,
                        effect: ShimmerEffect(
                          baseColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.4),
                        ),
                        child: Text(
                          santri?.noInduk ?? 'Nomor Induk',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildHeaderStat(
                      title: 'Total Poin',
                      value: '${santri?.totalPoin ?? 0}',
                      flex: 4,
                    ),
                    VerticalDivider(
                      color: Colors.white.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                    _buildHeaderStat(
                      title: 'Tahap Hafalan',
                      value: getTahapanLabel(santri?.tahapHafalan ?? '-'),
                      flex: 7,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat({
    required String title,
    required String value,
    int? flex,
  }) {
    final bool isLoading =
        controller.isLoading.value || controller.santriData.value == null;
    return Expanded(
      flex: flex ?? 1,
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
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
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ── Search + Toggle Bar (combined) ──────────────────────────────────────────

  Widget _buildSearchAndToggleBar() {
    return Obx(() {
      return Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!,
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: controller.filterMode.value == 'surah'
                      ? 'Cari surah...'
                      : 'Cari juz (1-30)...',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Colors.grey,
                            size: 18,
                          ),
                          onPressed: () {
                            controller.searchQuery.value = '';
                            controller.searchController.clear();
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 4,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Toggle Surah / Juz
          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.deepPurpleAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
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

  Color _progressColor(int current, int total) {
    if (current == 0) return Colors.red[400]!;
    if (current >= total) return const Color(0xFF10B981); // emerald green
    return Colors.orange[400]!;
  }

  // ── Juz Progress Card (compact) ─────────────────────────────────────────────

  Widget _buildJuzProgressCard(juz_model.Datum juz) {
    final progressParts = juz.progress?.split('/') ?? ['0', '0'];
    final currentAyat = int.tryParse(progressParts[0]) ?? 0;
    final totalAyat = juz.totalAyat ?? int.tryParse(progressParts[1]) ?? 0;
    final progressPercentage = totalAyat > 0 ? (currentAyat / totalAyat) : 0.0;
    final pct = (progressPercentage * 100).toStringAsFixed(0);

    final statusLabel = currentAyat == 0
        ? 'Belum Mulai'
        : currentAyat >= totalAyat
        ? 'Hafal'
        : 'Proses';

    final statusColor = currentAyat == 0
        ? Colors.red[600]!
        : currentAyat >= totalAyat
        ? const Color(0xFF059669)
        : Colors.orange[700]!;

    final statusBg = currentAyat == 0
        ? Colors.red[50]!
        : currentAyat >= totalAyat
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1: Nomor Juz + Nama + Status badge
            Row(
              children: [
                // Nomor badge
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${juz.juz}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent[700],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Label Juz
                Expanded(
                  child: Text(
                    'Juz ${juz.juz}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Progress bar + fraction + pct
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressColor(currentAyat, totalAyat),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$currentAyat/$totalAyat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($pct%)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _progressColor(currentAyat, totalAyat),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Surah Progress Card (compact) ───────────────────────────────────────────

  Widget _buildSurahProgressCard(Datum surah, int index) {
    final progressParts = surah.progress?.split('/') ?? ['0', '0'];
    final currentAyat = int.tryParse(progressParts[0]) ?? 0;
    final totalAyat = surah.totalAyat ?? int.tryParse(progressParts[1]) ?? 0;
    final progressPercentage = totalAyat > 0 ? (currentAyat / totalAyat) : 0.0;
    final pct = (progressPercentage * 100).toStringAsFixed(0);

    final statusLabel = currentAyat == 0
        ? 'Belum Mulai'
        : currentAyat >= totalAyat
        ? 'Hafal'
        : 'Proses';

    final statusColor = currentAyat == 0
        ? Colors.red[600]!
        : currentAyat >= totalAyat
        ? const Color(0xFF059669)
        : Colors.orange[700]!;

    final statusBg = currentAyat == 0
        ? Colors.red[50]!
        : currentAyat >= totalAyat
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Row 1: Nomor + Nama Surah + Status badge
            Row(
              children: [
                // Nomor badge
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
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
                const SizedBox(width: 10),
                // Nama Latin
                Expanded(
                  child: Text(
                    surah.namaLatin ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Row 2: Progress bar + fraction + pct
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressPercentage,
                      minHeight: 6,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _progressColor(currentAyat, totalAyat),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$currentAyat/$totalAyat',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($pct%)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _progressColor(currentAyat, totalAyat),
                  ),
                ),
              ],
            ),
          ],
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple[700]!, Colors.deepPurpleAccent],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
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
                    size: 22,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Doa setelah menyelesaikan pembacaan Al-Qur\'an',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: Colors.white,
                  size: 22,
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.manage_search_rounded,
                size: 48,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil pencarian',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba cari dengan kata kunci lain',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
