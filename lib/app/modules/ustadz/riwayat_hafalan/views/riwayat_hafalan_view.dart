import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan.dart';
import '../controllers/riwayat_hafalan_controller.dart';

class RiwayatHafalanView extends GetView<RiwayatHafalanController> {
  const RiwayatHafalanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Riwayat Hafalan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.refreshRiwayatHafalan,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allRiwayatData.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.deepPurpleAccent,
              ),
            ),
          );
        }

        final riwayat = controller.riwayatHafalan.value;
        if (riwayat == null || riwayat.santri == null) {
          return const Center(child: Text('Data tidak ditemukan'));
        }

        return Column(
          children: [
            // Santri Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.deepPurple[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 10,
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
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              riwayat.santri!.nama ?? 'Nama Santri',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tingkatan: ${riwayat.santri!.tingkatan ?? '-'}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
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
                        'Total Hafalan',
                        '${controller.riwayatHafalan.value?.pagination?.totalData}',
                        Icons.book,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoCard(
                        'Tahap',
                        riwayat.santri!.tahapHafalan ?? '-',
                        Icons.timeline,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Riwayat List
            Expanded(
              child: controller.allRiwayatData.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada riwayat hafalan',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async => controller.refreshRiwayatHafalan(),
                      child: ListView.builder(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount:
                            controller.allRiwayatData.length +
                            (controller.hasMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == controller.allRiwayatData.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            );
                          }

                          final datum = controller.allRiwayatData[index];
                          return _buildRiwayatCard(datum);
                        },
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
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

  Widget _buildRiwayatCard(Datum datum) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shadowColor: Colors.deepPurple.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          datum.namaSurah ?? '-',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        if (datum.namaSurahLatin != null)
                          Text(
                            datum.namaSurahLatin!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
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
                      color: _getStatusColor(datum.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      datum.status ?? '-',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDetailItem(
                    Icons.calendar_today,
                    'Tanggal',
                    datum.tanggal != null
                        ? DateFormat(
                            'dd MMM yyyy',
                            'id_ID',
                          ).format(datum.tanggal!)
                        : '-',
                  ),
                  const SizedBox(width: 24),
                  _buildDetailItem(
                    Icons.format_list_numbered,
                    'Jumlah Ayat',
                    '${datum.jumlahAyat ?? 0}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implement lihat detail
                        Get.snackbar(
                          'Info',
                          'Fitur lihat detail akan segera hadir',
                        );
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('Lihat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showDeleteConfirmation(datum);
                      },
                      icon: const Icon(Icons.delete, size: 18),
                      label: const Text('Hapus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'murajaah':
        return Colors.orange[400]!;
      case 'tambah hafalan':
        return Colors.green[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  void _showDeleteConfirmation(Datum datum) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus riwayat hafalan ${datum.namaSurah} pada ${DateFormat('dd MMM yyyy').format(datum.tanggal!)}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // TODO: Implement delete with proper ID
              Get.snackbar('Info', 'Fitur hapus akan segera hadir');
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
