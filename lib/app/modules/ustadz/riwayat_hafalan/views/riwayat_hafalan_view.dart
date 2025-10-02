import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan.dart';
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
        if (controller.isLoading.value && controller.allRiwayatData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B46C1)),
            ),
          );
        }

        final riwayat = controller.riwayatHafalan.value;
        if (riwayat == null || riwayat.santri == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }

        return RefreshIndicator(
          onRefresh: () async => controller.refreshRiwayatHafalan(),
          child: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              // Santri Header Card as Sliver
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurpleAccent,
                        Colors.deepPurple[700]!,
                      ],
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
                                Text(
                                  'Santri',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 0),
                                Text(
                                  riwayat.santri!.nama ?? 'Nama Santri',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                            'Total Setoran',
                            '${controller.riwayatHafalan.value?.pagination?.totalData ?? 0}',
                            Icons.book_rounded,
                          ),
                          const SizedBox(width: 12),
                          _buildInfoCard(
                            'Tahap Hafalan',
                            getTahapanLabel(
                              controller
                                      .riwayatHafalan
                                      .value
                                      ?.santri
                                      ?.tahapHafalan ??
                                  '-',
                            ),
                            // Icons.circle, // level 1
                            Icons.check_circle, // level 2
                            // Icons.check_circle_outline, // level 3
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Riwayat List
              if (controller.allRiwayatData.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.book_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat hafalan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == controller.allRiwayatData.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF6B46C1),
                              ),
                            ),
                          ),
                        );
                      }

                      final datum = controller.allRiwayatData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildRiwayatCard(
                          datum,
                          controller.riwayatHafalan.value!,
                        ),
                      );
                    },
                    childCount:
                        controller.allRiwayatData.length +
                        (controller.hasMore.value ? 1 : 0),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
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
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Datum datum, RiwayatHafalan riwayatHafalan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
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
                'santriId': riwayatHafalan.santri?.id,
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
                    const Spacer(),
                    // Small delete button
                    if (controller.userRole == 'ustadz')
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () =>
                            _showDeleteConfirmation(datum, riwayatHafalan),
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
        return const Color(0xFFFB923C);
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
        return 'Hafalan Baru';
      default:
        return status ?? '-';
    }
  }

  String getTahapanLabel(String tahapan) {
    switch (tahapan.toLowerCase()) {
      case 'level1':
        return 'Level 1';
      case 'level2':
        return 'Level 2';
      case 'level3':
        return 'Level 3';
      default:
        return '-';
    }
  }

  void _showDeleteConfirmation(Datum datum, RiwayatHafalan riwayatHafalan) {
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
                riwayatHafalan.santri!.id!,
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
