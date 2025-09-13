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

          // Student List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.santriList.isEmpty) {
                return _buildLoadingIndicator();
              } else if (controller.santriList.isEmpty) {
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

  Widget _buildSantriCard(DaftarSantri santri) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      shadowColor: Colors.grey[50],
      child: InkWell(
        onTap: () {
          Get.toNamed('/detail-santri', arguments: santri.id.toString());
        },
        onLongPress: () {
          Get.dialog(
            AlertDialog(
              title: Center(
                child: Text(
                  'Aksi',
                  style: TextStyle(
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.lightbulb),
                    title: const Text('Tambah Hafalan'),
                    onTap: () {
                      // Handle edit action
                      controller.statusSetoran.value = 'TambahHafalan';
                      Get.back();
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 16),

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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return DropdownButtonFormField<Surah>(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                      ),
                                      hint: const Text('Pilih Surah'),
                                      value: controller.selectedSurah.value,
                                      items: controller.surahList.map((
                                        Surah surah,
                                      ) {
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
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _BuildAyatHafalanDropdown(
                                                title: 'Mulai',
                                                value: controller
                                                    .selectedAyatMulai
                                                    .value,
                                                ayatList: controller.ayatList,
                                                otherSelectedAyat: controller
                                                    .selectedAyatAkhir
                                                    .value,
                                                onChanged: (AyatHafalan? ayat) {
                                                  controller
                                                          .selectedAyatMulai
                                                          .value =
                                                      ayat;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _BuildAyatHafalanDropdown(
                                                title: 'Selesai',
                                                value: controller
                                                    .selectedAyatAkhir
                                                    .value,
                                                ayatList: controller.ayatList,
                                                otherSelectedAyat: controller
                                                    .selectedAyatMulai
                                                    .value,
                                                isStartAyat: false,
                                                onChanged: (ayat) {
                                                  controller
                                                          .selectedAyatAkhir
                                                          .value =
                                                      ayat;
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                              child: const Text(
                                'Batal',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Handle save hafalan
                                controller.saveHafalan(santri.id.toString());
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.menu_book_rounded),
                    title: const Text('Murajaah'),
                    onTap: () {
                      // Handle murajaah action
                      controller.statusSetoran.value = 'Murajaah';
                      Get.back();
                      Get.dialog(
                        barrierDismissible: false,
                        AlertDialog(
                          insetPadding: EdgeInsets.symmetric(horizontal: 16),

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
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return DropdownButtonFormField<Surah>(
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                      ),
                                      hint: const Text('Pilih Surah'),
                                      value: controller.selectedSurah.value,
                                      items: controller.surahList.map((
                                        Surah surah,
                                      ) {
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
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    return Column(
                                      children: [
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _BuildAyatHafalanDropdown(
                                                title: 'Mulai',
                                                value: controller
                                                    .selectedAyatMulai
                                                    .value,
                                                ayatList: controller.ayatList,
                                                otherSelectedAyat: controller
                                                    .selectedAyatAkhir
                                                    .value,
                                                onChanged: (AyatHafalan? ayat) {
                                                  controller
                                                          .selectedAyatMulai
                                                          .value =
                                                      ayat;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _BuildAyatHafalanDropdown(
                                                title: 'Selesai',
                                                value: controller
                                                    .selectedAyatAkhir
                                                    .value,
                                                ayatList: controller.ayatList,
                                                otherSelectedAyat: controller
                                                    .selectedAyatMulai
                                                    .value,
                                                isStartAyat: false,
                                                onChanged: (ayat) {
                                                  controller
                                                          .selectedAyatAkhir
                                                          .value =
                                                      ayat;
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
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
                              child: const Text(
                                'Batal',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Handle save hafalan
                                controller.saveMurajaah(santri.id.toString());
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Simpan',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Riwayat Hafalan'),
                    onTap: () {
                      // Handle delete action
                      Get.back();
                      Get.toNamed(
                        '/riwayat-hafalan',
                        arguments: {'santriId': santri.id.toString()},
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Profile Picture
              Hero(
                tag: 'santri-${santri.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    controller.getImageUrl(santri.fotoProfil!),
                  ),
                  onBackgroundImageError: (exception, stackTrace) {
                    // Handle image loading error
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Student Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${santri.nama}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      controller.getTahapanSantri(santri.tahapHafalan!),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Wali: ${santri.orangTua?.nama ?? 'Tidak diketahui'}',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            santri.jenisKelamin == 'L'
                                ? 'Laki-laki'
                                : 'Perempuan',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Points Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${santri.totalPoin ?? 0} Poin',
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
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
        Text(
          'Data santri akan muncul di sini',
          style: TextStyle(color: Colors.grey[500], fontSize: 14),
        ),
      ],
    ),
  );
}
