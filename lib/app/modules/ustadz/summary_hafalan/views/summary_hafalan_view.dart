import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/summary_hafalan_juz.dart'
    as juz_model;
import 'package:mobile_kalimasada/app/data/models/summary_hafalan_surah.dart'
    as surah_model;
import 'package:mobile_kalimasada/app/widgets/level_info_dialog.dart';

import '../controllers/summary_hafalan_controller.dart';

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
                                ? _buildSurahCard(
                                    controller.summaryHafalanSurahList[index],
                                  )
                                : _buildJuzCard(
                                    controller.summaryHafalanJuzList[index],
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
            onTap: () => _showFilterBottomSheet(context),
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
        _buildLevelChip('Level 1', 'level1', const Color(0xFF10B981)),
        const SizedBox(width: 8),
        _buildLevelChip('Level 2', 'level2', const Color(0xFFF59E0B)),
        const SizedBox(width: 8),
        _buildLevelChip('Level 3', 'level3', const Color(0xFFEF4444)),
      ],
    );
  }

  Widget _buildLevelChip(String label, String value, Color color) {
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
                ? Colors.deepPurple.withValues(alpha: 0.12)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? Colors.deepPurple.withValues(alpha: 0.5)
                  : Colors.grey.shade200,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? Colors.deepPurple : Colors.grey[500],
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

  // FILTER BOTTOM SHEET (Status + Mode + Sort)

  void _showFilterBottomSheet(BuildContext context) {
    final tempStatus = controller.status.value.obs;
    final tempMode = controller.mode.value.obs;
    final tempSort = controller.filterBy.value.obs;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  const Icon(
                    Icons.tune_rounded,
                    color: Colors.deepPurpleAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Filter',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Status ───────────────────────────────────────────────
              _buildSheetSectionLabel('Status'),
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildSheetChip(
                      label: 'Hafalan',
                      value: 'tambahHafalan',
                      selected: tempStatus.value,
                      color: const Color(0xFF10B981),
                      onTap: (v) => tempStatus.value = v,
                    ),
                    _buildSheetChip(
                      label: 'Murajaah',
                      value: 'murajaah',
                      selected: tempStatus.value,
                      color: Colors.orangeAccent[700]!,
                      onTap: (v) => tempStatus.value = v,
                    ),
                    _buildSheetChip(
                      label: 'Tahsin',
                      value: 'tahsin',
                      selected: tempStatus.value,
                      color: Colors.blueAccent[700]!,
                      onTap: (v) => tempStatus.value = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Mode ─────────────────────────────────────────────────
              _buildSheetSectionLabel('Mode Tampilan'),
              const SizedBox(height: 8),
              Obx(
                () => Wrap(
                  spacing: 8,
                  children: [
                    _buildSheetChip(
                      label: 'Ayat',
                      value: 'surah',
                      selected: tempMode.value,
                      color: Colors.deepPurple,
                      onTap: (v) => tempMode.value = v,
                    ),
                    _buildSheetChip(
                      label: 'Halaman',
                      value: 'juz',
                      selected: tempMode.value,
                      color: Colors.deepPurple,
                      onTap: (v) => tempMode.value = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Sort — hanya muncul jika status = tambahHafalan ──────
              Obx(() {
                if (tempStatus.value != 'tambahHafalan') {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSheetSectionLabel('Urutan'),
                    const SizedBox(height: 8),
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        children: [
                          _buildSheetChip(
                            label: 'Terbanyak',
                            value: 'desc',
                            selected: tempSort.value,
                            color: Colors.deepPurple,
                            onTap: (v) => tempSort.value = v,
                          ),
                          _buildSheetChip(
                            label: 'Tersedikit',
                            value: 'asc',
                            selected: tempSort.value,
                            color: Colors.deepPurple,
                            onTap: (v) => tempSort.value = v,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // ── Buttons ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        tempStatus.value = 'tambahHafalan';
                        tempMode.value = 'surah';
                        tempSort.value = 'desc';
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        bool changed = false;

                        if (controller.status.value != tempStatus.value) {
                          controller.status.value = tempStatus.value;
                          changed = true;
                        }
                        if (controller.filterBy.value != tempSort.value) {
                          controller.filterBy.value = tempSort.value;
                          changed = true;
                        }
                        // mode via switchMode agar clearList juga dipanggil
                        if (controller.mode.value != tempMode.value) {
                          controller.mode.value = tempMode.value;
                          changed = true;
                        }
                        // jika status bukan tambahHafalan, reset sort ke desc
                        if (tempStatus.value != 'tambahHafalan') {
                          controller.filterBy.value = 'desc';
                        }

                        if (changed) {
                          controller.clearList();
                          controller.getSummaryHafalan();
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Terapkan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSheetSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSheetChip({
    required String label,
    required String value,
    required String selected,
    required Color color,
    required void Function(String) onTap,
  }) {
    final isActive = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : Colors.grey[200]!,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? color : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  // SURAH CARD

  Widget _buildSurahCard(surah_model.Datum item) {
    final terakhir = item.terakhirHafalan;
    final hasData = terakhir != null;
    final status = controller.status.value;

    final tanggal = hasData && terakhir.tanggal != null
        ? DateFormat('dd MMM yyyy', 'id_ID').format(terakhir.tanggal!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(item.id, item.nama, tanggal),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: hasData
                ? GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.toNamed(
                        '/detail-hafalan-surah',
                        arguments: {
                          'santriId': item.id,
                          'surahId': terakhir.surahId,
                        },
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        _buildInfoIcon(Icons.auto_stories_rounded),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                terakhir.surah ?? '-',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((terakhir.ayatDetail ?? '').isNotEmpty)
                                Text(
                                  'Ayat ${terakhir.ayatDetail}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                  )
                : _buildNoDataText(status),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Detail Riwayat',
                    icon: Icons.history_rounded,
                    color: Colors.orange,
                    enabled: hasData,
                    onTap: hasData
                        ? () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Get.toNamed(
                              '/detail-riwayat-hafalan',
                              arguments: {
                                'santriId': item.id,
                                'surahId': terakhir.surahId,
                                'tanggalRiwayat': terakhir.tanggal,
                                'status': terakhir.status,
                              },
                            );
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'Hafalan',
                    icon: Icons.book_rounded,
                    color: const Color(0xFF10B981),
                    enabled: true,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.toNamed(
                        '/progres-hafalan',
                        arguments: {'santriId': item.id.toString()},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // JUZ CARD

  Widget _buildJuzCard(juz_model.Datum item) {
    final terakhir = item.terakhirHafalan;
    final hasData = terakhir != null;
    final status = controller.status.value;

    final tanggal = hasData && terakhir.tanggal != null
        ? DateFormat('dd MMM yyyy', 'id_ID').format(terakhir.tanggal!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(item.id, item.nama, tanggal),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: hasData
                ? GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.toNamed(
                        '/detail-hafalan-juz',
                        arguments: {
                          'santriId': item.id,
                          'juzId': terakhir.juz,
                          'santriName': item.nama,
                        },
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      children: [
                        _buildInfoIcon(Icons.menu_book_rounded),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Juz ${terakhir.juz ?? '-'}',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if ((terakhir.halamanDetail ?? '').isNotEmpty)
                                Text(
                                  'Hal. ${terakhir.halamanDetail}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(status),
                      ],
                    ),
                  )
                : _buildNoDataText(status),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Detail Riwayat',
                    icon: Icons.history_rounded,
                    color: Colors.orange,
                    enabled: hasData,
                    onTap: hasData
                        ? () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Get.toNamed(
                              '/detail-riwayat-hafalan',
                              arguments: {
                                'santriId': item.id,
                                'juzId': terakhir.juz,
                                'tanggalRiwayat': terakhir.tanggal,
                                'status': terakhir.status,
                              },
                            );
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'Hafalan',
                    icon: Icons.menu_book_rounded,
                    color: Color(0xFF10B981),
                    enabled: true,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.toNamed(
                        '/progres-hafalan',
                        arguments: {'santriId': item.id.toString()},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SHARED CARD COMPONENTS

  Widget _buildCardHeader(int? santriId, String? nama, String? tanggal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.toNamed('/detail-santri', arguments: santriId.toString());
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  nama ?? 'Nama Santri',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (tanggal != null) _buildDateBadge(tanggal),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.person, size: 22, color: Colors.deepPurple),
    );
  }

  Widget _buildDateBadge(String tanggal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[600]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tanggal,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: Colors.deepPurple),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _statusLabel(status),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNoDataText(String status) {
    return Text(
      'Belum ada riwayat ${_statusLabel(status).toLowerCase()}',
      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled
            ? color.withValues(alpha: 0.1)
            : Colors.grey[100],
        foregroundColor: enabled ? color : Colors.grey[400],
        disabledBackgroundColor: Colors.grey[100],
        disabledForegroundColor: Colors.grey[400],
        shadowColor: Colors.transparent,
        elevation: 0,
        side: BorderSide(
          color: enabled ? color.withValues(alpha: 0.5) : Colors.grey[200]!,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        minimumSize: const Size(double.infinity, 42),
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

  // Badge count: status + mode (level tidak dihitung karena selalu visible)
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
              'Tidak ada data santri',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.searchQuery.value.isNotEmpty
                    ? 'Santri tidak ditemukan'
                    : 'Data santri akan muncul di sini',
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
