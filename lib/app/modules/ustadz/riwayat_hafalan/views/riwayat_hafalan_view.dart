import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../../services/auth_service.dart';
import '../controllers/riwayat_hafalan_controller.dart';

class RiwayatHafalanView extends GetView<RiwayatHafalanController> {
  const RiwayatHafalanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Riwayat Hafalan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshRiwayatHafalan();
          },
          color: Colors.deepPurple,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.scrollController,
            slivers: [_buildHeader(), _buildFilter(), _buildRiwayatList()],
          ),
        );
      }),
    );
  }

  Widget _buildRiwayatList() {
    if (controller.isLoading.value) {
      return _loadingState();
    }
    final isAyatMode = controller.filterMode.value == 'ayat';
    final items = isAyatMode
        ? controller.riwayatAyatData
        : controller.riwayatHalamanData;

    if (items.isEmpty) {
      return _buildEmptyState();
    } else {
      return SliverPadding(
        padding: const EdgeInsets.only(bottom: 40),
        sliver: _buildRiwayatListData(),
      );
    }
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildRiwayatCard(items[index], controller.profilSantri.value),
        );
      },
      itemCount: () {
        final isAyatMode = controller.filterMode.value == 'ayat';
        final items = isAyatMode
            ? controller.riwayatAyatData
            : controller.riwayatHalamanData;
        final hasMore = controller.hasMore.value;

        return items.length + (hasMore ? 1 : 0);
      }(),
    );
  }

  SliverFillRemaining _buildEmptyState() {
    return SliverFillRemaining(
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
                Icons.book_outlined,
                size: 48,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada riwayat hafalan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk refresh',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  SliverFillRemaining _loadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Memuat data...',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFilter() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: _buildDropdown(
                value: controller.filterMode.value,
                items: const [
                  DropdownMenuItem(value: 'ayat', child: Text('Ayat')),
                  DropdownMenuItem(value: 'halaman', child: Text('Halaman')),
                ],
                onChanged: (val) => controller.updateFilterMode(val!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDropdown(
                value: controller.filterStatus.value,
                items: const [
                  DropdownMenuItem(
                    value: 'TambahHafalan',
                    child: Text('Tambah Hafalan'),
                  ),
                  DropdownMenuItem(value: 'Murajaah', child: Text('Murajaah')),
                  DropdownMenuItem(value: 'Tahsin', child: Text('Tahsin')),
                ],
                onChanged: (val) => controller.updateFilterStatus(val!),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.deepPurple,
            size: 20,
          ),
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
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
                        enabled:
                            controller.isInitialLoading.value ||
                            controller.profilSantri.value == null,
                        effect: ShimmerEffect(
                          baseColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.4),
                        ),
                        child: Text(
                          controller.profilSantri.value?.nama ?? 'Nama Santri',
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
                        enabled:
                            controller.isInitialLoading.value ||
                            controller.profilSantri.value == null,
                        effect: ShimmerEffect(
                          baseColor: Colors.white.withValues(alpha: 0.2),
                          highlightColor: Colors.white.withValues(alpha: 0.4),
                        ),
                        child: Text(
                          controller.profilSantri.value?.noInduk ??
                              'Nomor Induk',
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
                      value: '${controller.profilSantri.value?.totalPoin ?? 0}',
                      flex: 4,
                    ),
                    VerticalDivider(
                      color: Colors.white.withValues(alpha: 0.2),
                      thickness: 1,
                    ),
                    _buildHeaderStat(
                      title: 'Tahap Hafalan',
                      value: getTahapanLabel(
                        controller.profilSantri.value?.tahapHafalan ?? '-',
                      ),
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
            enabled:
                controller.isInitialLoading.value ||
                controller.profilSantri.value == null,
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

  Widget _buildRiwayatCard(dynamic datum, dynamic santri) {
    if (santri == null || datum == null) return const SizedBox.shrink();
    final isAyatMode = controller.filterMode.value == 'ayat';

    final String title = isAyatMode
        ? (datum.namaSurahLatin ?? '-')
        : 'Juz ${datum.juz}';
    final String subtitle = isAyatMode
        ? (datum.namaSurahLatin ?? '')
        : (datum.surah as List).map((e) => e.namaLatin).join(', ');
    final String rangeLabel = isAyatMode
        ? 'Ayat ${datum.rangeAyat?.awal} - ${datum.rangeAyat?.akhir}'
        : 'Hal ${datum.rangeHalaman?.awal} - ${datum.rangeHalaman?.akhir}';

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            final args = {
              'santriId': santri.id,
              'tanggalRiwayat': datum.tanggal,
              'status': datum.status,
            };
            if (isAyatMode) {
              args['surahId'] = datum.surahId;
            } else {
              args['juzId'] = datum.juz;
            }
            Get.toNamed('/detail-riwayat-hafalan', arguments: args);
          },
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
                      child: Icon(
                        isAyatMode
                            ? Icons.auto_stories_rounded
                            : Icons.menu_book_rounded,
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
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (subtitle.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                rangeLabel,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                        color: _getStatusColor(
                          datum.status,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(
                            datum.status,
                          ).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        controller.getStatusText(datum.status),
                        style: GoogleFonts.poppins(
                          color: _getStatusColor(datum.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
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
                          _buildBadge(
                            Icons.calendar_month_rounded,
                            datum.tanggal != null
                                ? DateFormat(
                                    'dd MMM yyyy',
                                    'id_ID',
                                  ).format(datum.tanggal!)
                                : '-',
                          ),
                          if (controller.filterStatus.value == 'TambahHafalan')
                            _buildBadge(
                              Icons.auto_awesome_rounded,
                              '${datum.totalPoin ?? 0} poin',
                              color: Colors.amber[600],
                            ),
                        ],
                      ),
                    ),
                    if (AuthService.to.isUstadz)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => _showDeleteConfirmation(
                            datum,
                            santri,
                            isAyatMode,
                            subtitle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[600]!).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'murajaah':
        return Colors.orangeAccent[700]!;
      case 'tambahhafalan':
        return const Color(0xFF10B981);
      case 'tahsin':
        return Colors.blueAccent[700]!;
      default:
        return Colors.grey[600]!;
    }
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
              backgroundColor: Colors.red[500],
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
