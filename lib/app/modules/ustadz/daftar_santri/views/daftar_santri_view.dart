import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/ayat_hafalan.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:mobile_kalimasada/app/data/models/surah.dart';
import '../controllers/daftar_santri_controller.dart';

class DaftarSantriView extends GetView<DaftarSantriController> {
  const DaftarSantriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf1f5f9),
      appBar: AppBar(
        title: const Text(
          'Daftar Santri',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!,
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                onChanged: (value) {
                  controller.searchQuery.value = value;
                  controller.fetchData();
                },
                decoration: InputDecoration(
                  hintText: 'Cari santri...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                ),
              ),
            ),
          ),

          // Button Filter Tahap Hafalan
          buttonFilterTahapan(),

          const SizedBox(height: 8),
          // Student List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.santriList.isEmpty) {
                return _buildLoadingIndicator();
              } else if (controller.santriList.isEmpty) {
                return _buildEmptyState();
              } else if (controller.searchQuery.value.isNotEmpty &&
                  controller.santriList.isEmpty) {
                return _buildEmptyState();
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!controller.isLoading.value &&
                      !controller.isLoadingMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent &&
                      controller.hasMore) {
                    controller.loadMoreData();
                  }
                  return true;
                },
                child: RefreshIndicator(
                  onRefresh: () async {
                    controller.fetchData();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount:
                        controller.santriList.length +
                        (controller.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.santriList.length) {
                        return _buildLoadMoreIndicator();
                      }
                      final santri = controller.santriList[index];
                      return _buildSantriCard(santri);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Padding buttonFilterTahapan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Obx(
            () => Expanded(
              child: InkWell(
                onTap: () {
                  controller.tahapHafalan.value = 'level1';
                  controller.fetchData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.tahapHafalan.value == 'level1'
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.tahapHafalan.value == 'level1'
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Level 1',
                      style: TextStyle(
                        color: controller.tahapHafalan.value == 'level1'
                            ? Colors.deepPurple
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => Expanded(
              child: InkWell(
                onTap: () {
                  controller.tahapHafalan.value = 'level2';
                  controller.fetchData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.tahapHafalan.value == 'level2'
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.tahapHafalan.value == 'level2'
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Level 2',
                      style: TextStyle(
                        color: controller.tahapHafalan.value == 'level2'
                            ? Colors.deepPurple
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => Expanded(
              child: InkWell(
                onTap: () {
                  controller.tahapHafalan.value = 'level3';
                  controller.fetchData();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.tahapHafalan.value == 'level3'
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.tahapHafalan.value == 'level3'
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Level 3',
                      style: TextStyle(
                        color: controller.tahapHafalan.value == 'level3'
                            ? Colors.deepPurple
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriCard(Datum santri) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.grey.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () {
          Get.toNamed('/detail-santri', arguments: santri.id.toString());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Profile and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),
                    child: ClipOval(
                      child:
                          santri.fotoProfil != null &&
                              santri.fotoProfil!.isNotEmpty
                          ? Image.network(
                              santri.fotoProfil!,
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey[400],
                                );
                              },
                            )
                          : Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          santri.nama ?? 'Nama tidak tersedia',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),

                        // Badges Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Level Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTahapColor(
                                  santri.tahapHafalan,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getTahapColor(
                                    santri.tahapHafalan,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getTahapLabel(santri.tahapHafalan),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getTahapColor(santri.tahapHafalan),
                                ),
                              ),
                            ),

                            // Gender Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: santri.jenisKelamin?.toLowerCase() == 'l'
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.pink.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      santri.jenisKelamin?.toLowerCase() == 'l'
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.pink.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    santri.jenisKelamin?.toLowerCase() == 'l'
                                        ? Icons.male
                                        : Icons.female,
                                    size: 14,
                                    color:
                                        santri.jenisKelamin?.toLowerCase() ==
                                            'l'
                                        ? Colors.blue
                                        : Colors.pink,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    santri.jenisKelamin?.toLowerCase() == 'l'
                                        ? 'Laki-laki'
                                        : 'Perempuan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          santri.jenisKelamin?.toLowerCase() ==
                                              'l'
                                          ? Colors.blue
                                          : Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Points Badge
                            if (santri.totalPoin != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${santri.totalPoin} Poin',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber,
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
                ],
              ),

              const SizedBox(height: 16),

              // Action Buttons Section
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showMurajaahDialog(santri);
                      },
                      icon: const Icon(
                        Icons.menu_book_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Murajaah',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.green.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hafalan Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showHafalanDialog(santri);
                      },
                      icon: const Icon(
                        Icons.lightbulb,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Hafalan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent.withValues(
                          alpha: 0.8,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.deepPurpleAccent.withValues(
                          alpha: 0.3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  // Murajaah Button
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get color based on tahap hafalan
  Color _getTahapColor(String? tahap) {
    switch (tahap?.toLowerCase()) {
      case 'level1':
        return Colors.green;
      case 'level2':
        return Colors.orange;
      case 'level3':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get label based on tahap hafalan
  String _getTahapLabel(String? tahap) {
    switch (tahap?.toLowerCase()) {
      case 'level1':
        return 'Level 1';
      case 'level2':
        return 'Level 2';
      case 'level3':
        return 'Level 3';
      default:
        return 'Tahap ?';
    }
  }

  // Method to show hafalan dialog
  void _showHafalanDialog(Datum santri) {
    controller.statusSetoran.value = 'TambahHafalan';
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Tambah Hafalan',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              santri.nama!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(Get.context!).size.width - 80,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Surah Dropdown
                Obx(() {
                  if (controller.isLoadingSurah.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<Surah>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Pilih Surah'),
                    value: controller.selectedSurah.value,
                    items: controller.surahList.map((Surah surah) {
                      return DropdownMenuItem<Surah>(
                        value: surah,
                        child: Text(
                          '${surah.nomor}. ${surah.namaLatin} - ${surah.totalAyat} ayat',
                        ),
                      );
                    }).toList(),
                    onChanged: (Surah? newValue) {
                      final santriId = santri.id.toString();
                      controller.onSurahSelected(
                        newValue,
                        santriId,
                        controller.statusSetoran.value,
                      );
                    },
                    isExpanded: true,
                  );
                }),
                Obx(() {
                  if (controller.isLoadingAyat.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _BuildAyatHafalanDropdown(
                              title: 'Mulai',
                              value: controller.selectedAyatMulai.value,
                              ayatList: controller.ayatList,
                              otherSelectedAyat:
                                  controller.selectedAyatAkhir.value,
                              onChanged: (AyatHafalan? ayat) {
                                controller.selectedAyatMulai.value = ayat;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _BuildAyatHafalanDropdown(
                              title: 'Selesai',
                              value: controller.selectedAyatAkhir.value,
                              ayatList: controller.ayatList,
                              otherSelectedAyat:
                                  controller.selectedAyatMulai.value,
                              isStartAyat: false,
                              onChanged: (ayat) {
                                controller.selectedAyatAkhir.value = ayat;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                // Catatan Input
                const Text(
                  'Catatan',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  expands: false,
                  maxLines: 5,
                  controller: controller.catatanController,
                  decoration: InputDecoration(
                    hintText: 'Keterangan hafalan',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.selectedSurah.value = null;
              controller.selectedAyatMulai.value = null;
              controller.selectedAyatAkhir.value = null;
              controller.ayatList.clear();
              controller.statusSetoran.value = '';
              controller.catatanController.clear();
              Get.back();
            },
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.saveHafalan(santri.id.toString());
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  // Method to show murajaah dialog
  void _showMurajaahDialog(Datum santri) {
    controller.statusSetoran.value = 'Murajaah';
    Get.dialog(
      barrierDismissible: false,
      AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Murajaah',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              santri.nama!,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(Get.context!).size.width - 80,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Surah Dropdown
                Obx(() {
                  if (controller.isLoadingSurah.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<Surah>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    hint: const Text('Pilih Surah'),
                    value: controller.selectedSurah.value,
                    items: controller.surahList.map((Surah surah) {
                      return DropdownMenuItem<Surah>(
                        value: surah,
                        child: Text(
                          '${surah.nomor}. ${surah.namaLatin} - ${surah.totalAyat} ayat',
                        ),
                      );
                    }).toList(),
                    onChanged: (Surah? newValue) {
                      final santriId = santri.id.toString();
                      controller.onSurahSelected(
                        newValue,
                        santriId,
                        controller.statusSetoran.value,
                      );
                    },
                    isExpanded: true,
                  );
                }),
                Obx(() {
                  if (controller.isLoadingAyat.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _BuildAyatHafalanDropdown(
                              title: 'Mulai',
                              value: controller.selectedAyatMulai.value,
                              ayatList: controller.ayatList,
                              otherSelectedAyat:
                                  controller.selectedAyatAkhir.value,
                              onChanged: (AyatHafalan? ayat) {
                                controller.selectedAyatMulai.value = ayat;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _BuildAyatHafalanDropdown(
                              title: 'Selesai',
                              value: controller.selectedAyatAkhir.value,
                              ayatList: controller.ayatList,
                              otherSelectedAyat:
                                  controller.selectedAyatMulai.value,
                              isStartAyat: false,
                              onChanged: (ayat) {
                                controller.selectedAyatAkhir.value = ayat;
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),
                // Catatan Input
                const Text(
                  'Catatan',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                TextField(
                  expands: false,
                  maxLines: 5,
                  controller: controller.catatanController,
                  decoration: InputDecoration(
                    hintText: 'Keterangan murajaah',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.selectedSurah.value = null;
              controller.selectedAyatMulai.value = null;
              controller.selectedAyatAkhir.value = null;
              controller.ayatList.clear();
              controller.statusSetoran.value = '';
              controller.catatanController.clear();
              Get.back();
            },
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.saveHafalan(santri.id.toString());
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada data santri',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Text(
              controller.searchQuery.value.isNotEmpty &&
                      controller.santriList.isEmpty
                  ? 'Santri tidak ditemukan di ${controller.getTahapanFilter(controller.tahapHafalan.value)}'
                  : 'Data santri akan muncul di sini',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildAyatHafalanDropdown extends StatelessWidget {
  final String title;
  final AyatHafalan? value;
  final List<AyatHafalan> ayatList;
  final Function(AyatHafalan?) onChanged;
  final AyatHafalan? otherSelectedAyat;
  final bool isStartAyat;

  const _BuildAyatHafalanDropdown({
    required this.title,
    required this.value,
    required this.ayatList,
    required this.onChanged,
    this.otherSelectedAyat,
    this.isStartAyat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<AyatHafalan>(
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          value: value,
          hint: Text('Pilih Ayat $title'),
          isExpanded: true,
          items: ayatList.map((ayat) {
            final isDisabled =
                (ayat.checked == true ||
                (isStartAyat &&
                    otherSelectedAyat != null &&
                    ayat.nomorAyat! > otherSelectedAyat!.nomorAyat!) ||
                (!isStartAyat &&
                    otherSelectedAyat != null &&
                    ayat.nomorAyat! < otherSelectedAyat!.nomorAyat!));

            return DropdownMenuItem<AyatHafalan>(
              value: ayat,
              enabled: !isDisabled,
              child: Text(
                'Ayat ${ayat.nomorAyat}${ayat.checked == true ? ' (Sudah Dihafal)' : ''}',
                style: TextStyle(
                  color: isDisabled ? Colors.grey : null,
                  fontStyle: ayat.checked == true ? FontStyle.italic : null,
                ),
              ),
            );
          }).toList(),
          onChanged: (AyatHafalan? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }
}

Widget _buildLoadMoreIndicator() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
      ),
    ),
  );
}

Widget _buildLoadingIndicator() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
        ),
        const SizedBox(height: 16),
        const Text(
          'Memuat data...',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );
}
