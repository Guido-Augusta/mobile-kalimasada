import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/widgets/level_info_dialog.dart';

import '../controllers/summary_hafalan_controller.dart';
import '../widgets/summary_card_juz.dart';
import '../widgets/summary_card_surah.dart';
import '../widgets/summary_filter_bottom_sheet.dart';

class SummaryHafalanView extends GetView<SummaryHafalanController> {
  const SummaryHafalanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Riwayat Terakhir',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              LevelInfoDialog.show(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.getSummaryHafalan(),
        color: Colors.deepPurpleAccent,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Row 1: Search + Filter button ──────────────────
                    _buildSearchAndFilterRow(context),
                    const SizedBox(height: 10),

                    // ── Row 2: Level filter chips (langsung, tidak modal) ──
                    Obx(() => _buildLevelFilterRow()),
                    const SizedBox(height: 14),

                    // ── Active badge chips (status & mode, non-default) ──
                    Obx(() => _buildActiveFilterChips()),

                    // ── Content ──────────────────────────────────────────
                    Obx(() {
                      if (controller.isLoading.value) {
                        return _buildLoadingIndicator();
                      }
                      final isSurahMode = controller.mode.value == 'surah';
                      final isEmpty = isSurahMode
                          ? controller.summaryHafalanSurahList.isEmpty
                          : controller.summaryHafalanJuzList.isEmpty;

                      if (isEmpty) return _buildEmptyState();

                      final itemCount = isSurahMode
                          ? controller.summaryHafalanSurahList.length
                          : controller.summaryHafalanJuzList.length;

                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            itemCount + (controller.hasMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= itemCount) {
                            return _buildLoadMoreIndicator();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: isSurahMode
                                ? SummaryCardSurah(
                                    item: controller
                                        .summaryHafalanSurahList[index],
                                    status: controller.status.value,
                                  )
                                : SummaryCardJuz(
                                    item:
                                        controller.summaryHafalanJuzList[index],
                                    status: controller.status.value,
                                  ),
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ROW 1 — SEARCH + FILTER BUTTON

  Widget _buildSearchAndFilterRow(BuildContext context) {
    return Row(
      children: [
        // Search bar
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[200]!,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                onChanged: (v) => controller.searchQuery.value = v,
                style: GoogleFonts.poppins(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Cari santri...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  suffixIcon: controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey[400],
                            size: 18,
                          ),
                          onPressed: () {
                            controller.searchQuery.value = '';
                            controller.searchController.clear();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Filter button (badge count: status + mode non-default)
        Obx(() {
          final count = _activeFilterCount();
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              SummaryFilterBottomSheet.show(context);
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: count > 0 ? Colors.deepPurpleAccent : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: count > 0
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                        : Colors.grey[200]!,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 22,
                    color: count > 0 ? Colors.white : Colors.grey[600],
                  ),
                  if (count > 0)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurpleAccent[700],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ROW 2 — LEVEL FILTER (langsung, tidak di modal)

  Widget _buildLevelFilterRow() {
    return Row(
      children: [
        _buildLevelChip('Level 1', 'level1'),
        const SizedBox(width: 8),
        _buildLevelChip('Level 2', 'level2'),
        const SizedBox(width: 8),
        _buildLevelChip('Level 3', 'level3'),
      ],
    );
  }

  Widget _buildLevelChip(String label, String value) {
    final isActive = controller.level.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (controller.level.value == value) return;
          controller.level.value = value;
          controller.clearList();
          controller.getSummaryHafalan();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive
                ? Colors.deepPurpleAccent.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? Colors.deepPurpleAccent.withValues(alpha: 0.5)
                  : Colors.grey.shade200,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.deepPurpleAccent : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  // ACTIVE FILTER CHIPS (status & mode jika non-default)

  Widget _buildActiveFilterChips() {
    final statusDefault = controller.status.value == 'tambahHafalan';
    final modeDefault = controller.mode.value == 'surah';

    if (statusDefault && modeDefault) return const SizedBox(height: 4);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          if (!statusDefault)
            _buildFilterChipBadge(
              _statusLabel(controller.status.value),
              _statusColor(controller.status.value),
              () {
                controller.status.value = 'tambahHafalan';
                controller.filterBy.value = 'desc';
                controller.clearList();
                controller.getSummaryHafalan();
              },
            ),
          if (!modeDefault)
            _buildFilterChipBadge('Mode: Halaman', Colors.deepPurple[400]!, () {
              controller.switchMode('surah');
            }),
        ],
      ),
    );
  }

  Widget _buildFilterChipBadge(
    String label,
    Color color,
    VoidCallback onRemove,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(10),
            child: Icon(Icons.close_rounded, size: 14, color: color),
          ),
        ],
      ),
    );
  }

  // STATUS & LEVEL HELPERS

  Color _statusColor(String status) {
    switch (status) {
      case 'murajaah':
        return Colors.orangeAccent[700]!;
      case 'tahsin':
        return Colors.blueAccent[700]!;
      default:
        return const Color(0xFF10B981);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'murajaah':
        return 'Murajaah';
      case 'tahsin':
        return 'Tahsin';
      default:
        return 'Hafalan';
    }
  }

  int _activeFilterCount() {
    int count = 0;
    if (controller.status.value != 'tambahHafalan') count++;
    if (controller.mode.value != 'surah') count++;
    return count;
  }

  // EMPTY / LOADING

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              controller.appliedSearchQuery.value.isNotEmpty
                  ? 'Santri tidak ditemukan'
                  : 'Tidak ada data santri',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.appliedSearchQuery.value.isNotEmpty
                    ? 'Santri tidak ditemukan di tahap ini'
                    : 'Tarik ke bawah untuk refresh',
                style: GoogleFonts.poppins(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
        ),
      ),
    );
  }
}
