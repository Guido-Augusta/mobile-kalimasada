import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/riwayat_hafalan_controller.dart';

class RiwayatHafalanView extends GetView<RiwayatHafalanController> {
  const RiwayatHafalanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Riwayat Hafalan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () async {
            controller.refreshRiwayatHafalan();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: controller.scrollController,
            slivers: [
              _buildHeader(),
              _buildFilter(),
              _buildTotalSetoran(),
              _buildRiwayatList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildRiwayatList() {
    if (controller.isLoading.value) {
      return _loadingState();
    }
    if ((controller.filterType.toLowerCase() == 'tambahhafalan' &&
            controller.riwayatHafalanData.isEmpty) ||
        (controller.filterType.toLowerCase() == 'murajaah' &&
            controller.riwayatMurajaahData.isEmpty)) {
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
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final isHafalan =
            controller.filterType.toLowerCase() == 'tambahhafalan';
        final items = isHafalan
            ? controller.riwayatHafalanData
            : controller.riwayatMurajaahData;
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildRiwayatCard(
            items[index],
            controller.profilSantri.value!,
          ),
        );
      },
      itemCount: () {
        final isHafalan =
            controller.filterType.toLowerCase() == 'tambahhafalan';
        final items = isHafalan
            ? controller.riwayatHafalanData
            : controller.riwayatMurajaahData;
        final hasMore = isHafalan
            ? controller.hasMoreHafalan.value
            : controller.hasMoreMurajaah.value;

        // Add 1 to item count if there are more items to load
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
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk refresh',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  SliverFillRemaining _loadingState() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data...'),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildTotalSetoran() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Align(
          alignment: Alignment.centerRight,
          child: Skeletonizer(
            enabled:
                controller.isLoading.value ||
                controller.profilSantri.value == null,
            child: Text(
              '${controller.filterType.toLowerCase() == 'tambahhafalan' ? controller.totalSetoranHafalan : controller.totalSetoranMurajaah} Setoran',
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFilter() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildFilterButton(
              'Tambah Hafalan',
              controller.filterType.value == 'TambahHafalan',
              onTap: () => controller.updateFilter('TambahHafalan'),
            ),
            const SizedBox(width: 12),
            _buildFilterButton(
              'Murajaah',
              controller.filterType.value == 'Murajaah',
              onTap: () => controller.updateFilter('Murajaah'),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
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
                            controller.profilSantri.value == null,
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
                                controller.profilSantri.value?.nama ??
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
                            controller.profilSantri.value == null,
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
                                controller.profilSantri.value?.noInduk ??
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
                  '${controller.profilSantri.value?.totalPoin ?? 'Poin'}',
                ),
                const SizedBox(width: 12),
                _buildInfoCard(
                  'Tahap Hafalan',
                  getTahapanLabel(
                    controller.profilSantri.value?.tahapHafalan ?? '-',
                  ),
                  flex: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                  controller.profilSantri.value == null,
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
                  controller.profilSantri.value == null,
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

  Widget _buildRiwayatCard(Datum datum, Santri santri) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.toNamed(
            '/detail-riwayat-hafalan',
            arguments: {
              'santriId': santri.id,
              'surahId': datum.surahId,
              'tanggalRiwayat': datum.tanggal,
              'status': datum.status,
            },
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          datum.namaSurah ?? '-',
                          style: GoogleFonts.amiri(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B46C1),
                          ),
                        ),
                        if (datum.namaSurahLatin != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              datum.namaSurahLatin!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
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
                      color: _getStatusColor(datum.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(datum.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDetailItem(
                    Icons.calendar_today_rounded,
                    datum.tanggal != null
                        ? DateFormat(
                            'dd MMM yyyy',
                            'id_ID',
                          ).format(datum.tanggal!)
                        : '-',
                  ),
                  const SizedBox(width: 24),
                  _buildDetailItem(
                    Icons.format_list_numbered_rounded,
                    '${datum.jumlahAyat ?? 0} ayat',
                  ),
                  if (controller.filterType.value == 'TambahHafalan')
                    const SizedBox(width: 24),
                  if (controller.filterType.value == 'TambahHafalan')
                    _buildDetailItem(
                      Icons.star_rounded,
                      '${datum.totalPoin ?? 0} poin',
                    ),
                  const Spacer(),
                  // Small delete button
                  if (controller.userRole == 'ustadz')
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showDeleteConfirmation(datum, santri),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isActive, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive
                  ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                  : Colors.grey[300]!,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.deepPurple : Colors.grey[700],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'murajaah':
        return Colors.orangeAccent;
      case 'tambahhafalan':
        return const Color(0xFF10B981);
      default:
        return Colors.grey[400]!;
    }
  }

  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'murajaah':
        return 'Murajaah';
      case 'tambahhafalan':
        return 'Tambah Hafalan';
      default:
        return status ?? '-';
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

  void _showDeleteConfirmation(Datum datum, Santri santri) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Anda yakin ingin menghapus riwayat hafalan ${datum.namaSurahLatin} pada ${DateFormat('dd MMM yyyy', 'id_ID').format(datum.tanggal!)}?',
          style: TextStyle(color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          const SizedBox(width: 2),
          ElevatedButton(
            onPressed: () {
              controller.deleteRiwayatHafalan(
                santri.id!,
                datum.surahId!,
                DateFormat('yyyy-MM-dd', 'id_ID').format(datum.tanggal!),
                datum.status!,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
