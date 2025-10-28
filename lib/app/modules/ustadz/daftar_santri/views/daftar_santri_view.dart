import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/ayat_hafalan.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:mobile_kalimasada/app/data/models/surah.dart';
import 'package:searchfield/searchfield.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              // dialog informasi level
              showLevelInfoDialog(context);
            },
          ),
        ],
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
              return RefreshIndicator(
                onRefresh: () async {
                  controller.fetchData();
                },
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  itemCount:
                      controller.santriList.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.santriList.length) {
                      return _buildLoadMoreIndicator();
                    }
                    final santri = controller.santriList[index];
                    return _buildSantriCard(santri);
                  },
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
                          santri.fotoProfil != null ||
                              santri.fotoProfil!.isNotEmpty ||
                              santri.fotoProfil! != ''
                          ? CachedNetworkImage(
                              imageUrl: controller.getImageUrl(
                                santri.fotoProfil!,
                              ),
                              fit: BoxFit.cover,
                              width: 60,
                              height: 60,
                              placeholder: (context, url) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[400],
                              ),
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
                  // Murajaah Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Check if surah list is empty
                        if (controller.surahList.isEmpty) {
                          await controller.fetchSurahs();
                          if (controller.surahList.isEmpty) {
                            return;
                          }
                        }
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
                        backgroundColor: Colors.orangeAccent.withValues(
                          alpha: 0.8,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.orangeAccent.withValues(alpha: 0.3),
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
                      onPressed: () async {
                        // Check if surah list is empty
                        if (controller.surahList.isEmpty) {
                          await controller.fetchSurahs();
                          if (controller.surahList.isEmpty) {
                            return;
                          }
                        }
                        showHafalanDialog(santri);
                      },
                      icon: const Icon(
                        Icons.book,
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
  void showHafalanDialog(Datum santri) {
    controller.statusSetoran.value = 'TambahHafalan';
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Tambah Hafalan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      santri.nama!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tanggal Hari ini
                    Text(
                      '${_getHariIni()}, ${_formatTanggal(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getTahapColor(santri.tahapHafalan),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getTahapLabel(santri.tahapHafalan),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: controller.formKeyHafalan,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Surah Search
                        Obx(() {
                          if (controller.isLoadingSurah.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pilih Surah',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SearchField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harap pilih surah';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                suggestions: controller.surahList.map((
                                  Surah surah,
                                ) {
                                  return SearchFieldListItem<Surah>(
                                    surah.namaLatin!,
                                    value: surah.namaLatin,
                                    item: surah,
                                    key: ValueKey(surah.id),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${surah.nomor}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          surah.namaLatin!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${surah.totalAyat!} Ayat',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                selectedValue:
                                    controller.selectedSurahHafalan.value,
                                onSuggestionTap: (SearchFieldListItem x) {
                                  controller.selectedSurahHafalan.value =
                                      x as SearchFieldListItem<Surah>;
                                  controller.onSurahSelected(
                                    x.item,
                                    santri.id.toString(),
                                    'TambahHafalan',
                                  );
                                },
                                suggestionState: Suggestion.expand,
                                textInputAction: TextInputAction.next,
                                suggestionsDecoration: SuggestionDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                searchInputDecoration: SearchInputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Cari surah...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  suffixIcon: Obx(() {
                                    if (controller.selectedSurahHafalan.value !=
                                        null) {
                                      return IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          controller
                                                  .selectedSurahHafalan
                                                  .value =
                                              null;
                                          controller.detailHafalan.value = null;
                                          controller.inputJumlahAyatController
                                              .clear();
                                          controller.ayatList.clear();
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                  fillColor: Colors.grey[50],
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 20),

                        // Jumlah Ayat
                        Obx(() {
                          if (controller.isLoadingAyat.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jumlah Ayat',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harap masukkan jumlah ayat';
                                  }
                                  if (int.parse(value) <= 0) {
                                    return 'Jumlah ayat harus lebih dari 0';
                                  }
                                  return null;
                                },
                                enabled: controller.detailHafalan.value != null,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Masukkan jumlah ayat',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  fillColor: Colors.grey[50],
                                  filled: true,
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.format_list_numbered,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                                controller:
                                    controller.inputJumlahAyatController,
                                onChanged: (value) {
                                  controller.inputJumlahAyatController.text =
                                      value;
                                },
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 20),

                        // Catatan
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catatan',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: TextField(
                                controller: controller.catatanController,
                                maxLines: 5,
                                minLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Keterangan hafalan (opsional)',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  border: InputBorder.none,
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  prefixIcon: const Padding(
                                    padding: EdgeInsets.only(bottom: 40),
                                    child: Icon(
                                      Icons.note_alt_outlined,
                                      color: Colors.deepPurpleAccent,
                                    ),
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

              // Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          controller.selectedSurahHafalan.value = null;
                          controller.inputJumlahAyatController.text = '';
                          controller.ayatList.clear();
                          controller.statusSetoran.value = '';
                          controller.catatanController.clear();
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: () {
                            if (controller.formKeyHafalan.currentState!
                                .validate()) {
                              controller.saveHafalan(santri.id.toString());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: controller.isSaveLoading.value
                                ? EdgeInsets.symmetric(vertical: 4)
                                : EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSaveLoading.value
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Simpan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Method to show hafalan dialog
  void _showMurajaahDialog(Datum santri) {
    controller.statusSetoran.value = 'Murajaah';
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Murajaah',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      santri.nama!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tanggal Hari ini
                    Text(
                      '${_getHariIni()}, ${_formatTanggal(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 10),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getTahapColor(santri.tahapHafalan),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getTahapLabel(santri.tahapHafalan),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: controller.formKeyMurajaah,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Surah Search
                        Obx(() {
                          if (controller.isLoadingSurah.value) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.deepPurpleAccent,
                                  ),
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pilih Surah',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SearchField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Harap pilih surah';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                suggestions: controller.surahList.map((
                                  Surah surah,
                                ) {
                                  return SearchFieldListItem<Surah>(
                                    surah.namaLatin!,
                                    value: surah.namaLatin,
                                    item: surah,
                                    key: ValueKey(surah.id),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.deepPurple.withValues(
                                              alpha: 0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${surah.nomor}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.deepPurple,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          surah.namaLatin!,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${surah.totalAyat!} Ayat',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                selectedValue:
                                    controller.selectedSurahMurajaah.value,
                                onSuggestionTap: (SearchFieldListItem x) {
                                  controller.selectedSurahMurajaah.value =
                                      x as SearchFieldListItem<Surah>;
                                  controller.onSurahSelected(
                                    x.item,
                                    santri.id.toString(),
                                    'Murajaah',
                                  );
                                },
                                suggestionState: Suggestion.expand,
                                textInputAction: TextInputAction.next,
                                suggestionsDecoration: SuggestionDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                searchInputDecoration: SearchInputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  hintText: 'Cari surah...',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: Colors.deepPurpleAccent,
                                  ),
                                  suffixIcon: Obx(() {
                                    if (controller
                                            .selectedSurahMurajaah
                                            .value !=
                                        null) {
                                      return IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.grey,
                                        ),
                                        onPressed: () {
                                          controller
                                                  .selectedSurahMurajaah
                                                  .value =
                                              null;
                                          controller.selectedAyatMulai.value =
                                              null;
                                          controller.selectedAyatAkhir.value =
                                              null;
                                          controller.ayatList.clear();
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }),
                                  fillColor: Colors.grey[50],
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),

                        const SizedBox(height: 20),

                        // Ayat Dropdown
                        Obx(() {
                          return Row(
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
                          );
                        }),

                        const SizedBox(height: 20),

                        // Catatan
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catatan',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller.catatanController,
                              maxLines: 5,
                              minLines: 3,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: 'Keterangan hafalan (opsional)',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurpleAccent,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 40),
                                  child: Icon(
                                    Icons.note_alt_outlined,
                                    color: Colors.deepPurpleAccent,
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

              // Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          controller.selectedSurahMurajaah.value = null;
                          controller.selectedAyatMulai.value = null;
                          controller.selectedAyatAkhir.value = null;
                          controller.ayatList.clear();
                          controller.statusSetoran.value = '';
                          controller.catatanController.clear();
                          Get.back();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.grey[400]!),
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: () {
                            if (controller.formKeyMurajaah.currentState!
                                .validate()) {
                              controller.saveMurajaah(santri.id.toString());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: controller.isSaveLoading.value
                                ? EdgeInsets.symmetric(vertical: 4)
                                : EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Obx(
                            () => controller.isSaveLoading.value
                                ? Transform.scale(
                                    scale: 0.5,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Simpan',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () async {
        controller.fetchData();
      },
      child: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100),
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
        ],
      ),
    );
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

  void showLevelInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informasi Level Hafalan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6B46C1),
                ),
              ),
              const SizedBox(height: 16),
              _buildLevelInfo(
                context,
                title: 'Level 1',
                description: 'Juz 30',
                color: const Color(0xFF10B981), // Green
              ),
              const SizedBox(height: 12),
              _buildLevelInfo(
                context,
                title: 'Level 2',
                description: 'Surah Pilihan',
                color: const Color(0xFFF59E0B), // Amber
              ),
              const SizedBox(height: 12),
              _buildLevelInfo(
                context,
                title: 'Level 3',
                description: 'Juz 1-29',
                color: const Color(0xFFEF4444), // Red
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Mengerti',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelInfo(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method untuk mendapatkan nama hari dalam bahasa Indonesia
  String _getHariIni() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  // Method untuk memformat tanggal dalam format Indonesia (contoh: 10 Oktober 2023)
  String _formatTanggal(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
        Obx(
          () => DropdownButtonFormField<AyatHafalan>(
            validator: (value) {
              if (value == null) {
                return 'Harap pilih ayat';
              }
              return null;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            dropdownColor: Colors.white,
            initialValue: value,
            hint: Text(
              'Pilih Ayat $title',
              style: TextStyle(color: Colors.grey[500]),
            ),
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
        ),
      ],
    );
  }
}
