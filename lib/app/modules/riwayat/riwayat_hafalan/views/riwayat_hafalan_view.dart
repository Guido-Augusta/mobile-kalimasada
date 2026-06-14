import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_ayat.dart'
    as model_ayat;
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_halaman.dart'
    as model_halaman;

import '../controllers/riwayat_hafalan_controller.dart';
import '../widgets/riwayat_ayat_card.dart';
import '../widgets/riwayat_halaman_card.dart';
import '../widgets/riwayat_empty_state.dart';
import '../widgets/riwayat_filter.dart';
import '../widgets/riwayat_header.dart';

class RiwayatHafalanView extends GetView<RiwayatHafalanController> {
  const RiwayatHafalanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Riwayat Hafalan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        return SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () => controller.refreshRiwayatHafalan(),
            color: Colors.deepPurpleAccent,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              controller: controller.scrollController,
              slivers: [_buildHeader(), _buildFilter(), _buildRiwayatList()],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRiwayatList() {
    final isAyatMode = controller.filterMode.value == 'ayat';
    final items = isAyatMode
        ? controller.riwayatAyatData
        : controller.riwayatHalamanData;

    final isLoading = controller.isLoading.value;

    if (isLoading && items.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.only(bottom: 40),
        sliver: Skeletonizer.sliver(
          enabled: true,
          child: SliverList.separated(
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildDummyCard(),
              );
            },
            itemCount: 4,
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return const SliverFillRemaining(child: RiwayatEmptyState());
    }

    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 40),
      sliver: Skeletonizer.sliver(
        enabled: isLoading,
        child: _buildRiwayatListData(),
      ),
    );
  }

  Widget _buildDummyCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.deepPurpleAccent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nama Surah Placeholder',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Ayat 1 - 10',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Hafalan',
                    style: GoogleFonts.poppins(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, color: Colors.grey[200]),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[600]!.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '12 Jun 2026',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[600]!.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              size: 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '10 poin',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  SliverList _buildRiwayatListData() {
    return SliverList.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final isAyatMode = controller.filterMode.value == 'ayat';
        final items = isAyatMode
            ? controller.riwayatAyatData
            : controller.riwayatHalamanData;

        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.deepPurpleAccent,
                ),
              ),
            ),
          );
        }

        final santri = controller.profilSantri.value;
        if (santri == null) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: isAyatMode
              ? RiwayatAyatCard(
                  datum: items[index] as model_ayat.Datum,
                  santri: santri,
                  filterStatus: controller.filterStatus.value,
                  getStatusText: controller.getStatusText,
                  onDelete: (datum, santri, subtitle) {
                    _showDeleteConfirmation(datum, santri, true, subtitle);
                  },
                )
              : RiwayatHalamanCard(
                  datum: items[index] as model_halaman.Datum,
                  santri: santri,
                  filterStatus: controller.filterStatus.value,
                  getStatusText: controller.getStatusText,
                  onDelete: (datum, santri, subtitle) {
                    _showDeleteConfirmation(datum, santri, false, subtitle);
                  },
                ),
        );
      },
      itemCount: () {
        final isAyatMode = controller.filterMode.value == 'ayat';
        final items = isAyatMode
            ? controller.riwayatAyatData
            : controller.riwayatHalamanData;
        final hasMore = controller.hasMore.value;
        final isLoadingMore = controller.isLoadingMore.value;

        return items.length + (hasMore && isLoadingMore ? 1 : 0);
      }(),
    );
  }

  SliverToBoxAdapter _buildFilter() {
    return SliverToBoxAdapter(
      child: RiwayatFilter(
        filterMode: controller.filterMode.value,
        filterStatus: controller.filterStatus.value,
        onModeChanged: controller.updateFilterMode,
        onStatusChanged: controller.updateFilterStatus,
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    final santri = controller.profilSantri.value;
    final bool isLoading = controller.isLoading.value && santri == null;

    return SliverToBoxAdapter(
      child: RiwayatHeader(
        santri: santri,
        isLoading: isLoading,
        tahapanLabel: getTahapanLabel(santri?.tahapHafalan ?? '-'),
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

  void _showDeleteConfirmation(
    dynamic datum,
    dynamic santri,
    bool isAyatMode,
    String subtitle,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red[400],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Hapus Riwayat',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${DateFormat('dd MMM yyyy', 'id_ID').format(datum.tanggal!)} (${isAyatMode ? subtitle : "Juz ${datum.juz}"})',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Apakah Anda yakin ingin menghapus riwayat ${controller.getStatusText(datum.status)} ini?',
              style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 14),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteRiwayatHafalan(
                santriId: santri.id!,
                tanggal: DateFormat(
                  'yyyy-MM-dd',
                  'id_ID',
                ).format(datum.tanggal!),
                status: datum.status!,
                surahId: isAyatMode ? datum.surahId : null,
                juzId: isAyatMode ? null : datum.juz,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
