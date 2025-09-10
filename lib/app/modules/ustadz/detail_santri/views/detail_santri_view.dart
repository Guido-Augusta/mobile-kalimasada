import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/detail_santri_controller.dart';

class DetailSantriView extends GetView<DetailSantriController> {
  const DetailSantriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detail Santri',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final santri = controller.santriDetail.value;
        if (santri == null) {
          return const Center(child: Text('Data santri tidak ditemukan'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.deepPurpleAccent,
                          width: 3,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            controller.getImageUrl(santri.fotoProfil!),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      santri.nama ?? 'Nama tidak tersedia',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${santri.tingkatan ?? 'Tingkat'} • ${santri.tahapHafalan ?? 'Tahap 0'}',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Poin', '${santri.totalPoin ?? 0}'),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                    ),
                    _buildStatItem('Peringkat', '${santri.peringkat ?? 'N/A'}'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Personal Information Section
              _buildSectionTitle('Informasi Pribadi'),
              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    'Email',
                    santri.user?.email ?? 'Tidak ada data',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Jenis Kelamin',
                    santri.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'Tanggal Lahir',
                    santri.tanggalLahir != null
                        ? DateFormat(
                            'dd MMMM yyyy',
                            'id_ID',
                          ).format(santri.tanggalLahir!)
                        : 'Tidak ada data',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    'No. Telepon',
                    santri.nomorHp ?? 'Tidak ada data',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Alamat', santri.alamat ?? 'Tidak ada data'),
                ],
              ),

              const SizedBox(height: 16),

              // Orang Tua Section
              _buildSectionTitle('Orang Tua'),
              _buildInfoCard(
                children: [
                  _buildInfoRow(
                    'Nama',
                    santri.orangTua?.nama ?? 'Tidak ada data',
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.deepPurpleAccent,
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurpleAccent,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.history, color: Colors.deepPurpleAccent),
              label: const Text('Riwayat'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.deepPurpleAccent,
                side: const BorderSide(color: Colors.deepPurpleAccent),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                // Navigate to history page
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                'Hafalan',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Get.toNamed(
                  '/progres-hafalan',
                  arguments: {'santriId': controller.santriId},
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
