import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/summary_hafalan.dart';

import '../controllers/summary_hafalan_controller.dart';

class SummaryHafalanView extends GetView<SummaryHafalanController> {
  const SummaryHafalanView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf1f5f9),
      appBar: AppBar(
        title: const Text(
          'Riwayat Terakhir',
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
      body: RefreshIndicator(
        onRefresh: () async {
          controller.getSummaryHafalan();
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: controller.scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
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
                          controller.getSummaryHafalan();
                        },
                        decoration: InputDecoration(
                          hintText: 'Cari santri...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: controller.status.value,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  dropdownColor: Colors.white,
                                  items: [
                                    _buildDropdownItem(
                                      'tambahHafalan',
                                      'Tambah Hafalan',
                                    ),
                                    _buildDropdownItem('murajaah', 'Murajaah'),
                                  ],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      controller.status.value = newValue;
                                      controller.getSummaryHafalan();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Obx(
                              () => DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: controller.level.value,
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  dropdownColor: Colors.white,
                                  items: [
                                    _buildDropdownItem('level1', 'Level 1'),
                                    _buildDropdownItem('level2', 'Level 2'),
                                    _buildDropdownItem('level3', 'Level 3'),
                                  ],
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      controller.level.value = newValue;
                                      controller.getSummaryHafalan();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                'Riwayat ${controller.status.value == 'murajaah' ? 'Murajaah' : 'Hafalan'} Terakhir',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),

                          // Filter asc/desc
                          if (controller.status.value == 'tambahHafalan')
                            InkWell(
                              onTap: () {
                                controller.updateFilterBy();
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: Container(
                                margin: const EdgeInsets.only(left: 16),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Obx(
                                  () => Transform.flip(
                                    flipY: controller.filterBy.value == 'asc',
                                    child: Icon(
                                      Icons.sort_rounded,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      if (controller.isLoading.value) {
                        return _buildLoadingIndicator();
                      }
                      if (controller.summaryHafalanList.isEmpty) {
                        return _buildEmptyState();
                      }
                      return ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount:
                            controller.summaryHafalanList.length +
                            (controller.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= controller.summaryHafalanList.length) {
                            return _buildLoadMoreIndicator();
                          }
                          final summaryHafalan =
                              controller.summaryHafalanList[index];
                          return _buildSummaryHafalanCard(summaryHafalan);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 4);
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

  DropdownMenuItem<String> _buildDropdownItem(String value, String text) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.grey[600],
          fontWeight: FontWeight.w400,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  Widget _buildSummaryHafalanCard(Datum summaryHafalan) {
    final isMurajaah = controller.status.value == 'murajaah';
    final hasLastHafalan = summaryHafalan.terakhirHafalan != null;
    final surahName =
        summaryHafalan.terakhirHafalan?.surah ?? 'Belum ada hafalan';
    final ayatDetail = summaryHafalan.terakhirHafalan?.ayatDetail ?? '-';
    final tanggal = hasLastHafalan
        ? DateFormat(
            'dd MMM yyyy',
            'id_ID',
          ).format(summaryHafalan.terakhirHafalan!.tanggal!)
        : '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            '/detail-santri',
            arguments: summaryHafalan.id.toString(),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.grey[50]!],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with name and date
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and ID
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summaryHafalan.nama ?? 'Nama Santri',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          summaryHafalan.noInduk ?? '-',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Date badge
                  if (hasLastHafalan)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.deepPurple[100]!),
                      ),
                      child: Text(
                        tanggal,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Last hafalan info
              if (hasLastHafalan)
                InkWell(
                  onTap: () {
                    Get.toNamed(
                      '/detail-progres',
                      arguments: {
                        'santriId': summaryHafalan.id,
                        'surahId': summaryHafalan.terakhirHafalan?.surahId,
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Surah icon
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: Colors.deepPurple[600],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Surah info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                surahName,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ayat $ayatDetail',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isMurajaah
                                ? Colors.orange[50]
                                : Colors.green[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isMurajaah
                                  ? Colors.orange[100]!
                                  : Colors.green[100]!,
                            ),
                          ),
                          child: Text(
                            isMurajaah ? 'Murajaah' : 'Hafalan',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isMurajaah
                                  ? Colors.orange[800]
                                  : Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      'Belum ada riwayat ${isMurajaah ? 'murajaah' : 'hafalan'}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  // Detail Button
                  Expanded(
                    flex: 5,
                    child: ElevatedButton.icon(
                      onPressed: hasLastHafalan
                          ? () {
                              Get.toNamed(
                                '/detail-riwayat-hafalan',
                                arguments: {
                                  'santriId': summaryHafalan.id,
                                  'surahId':
                                      summaryHafalan.terakhirHafalan?.surahId,
                                  'tanggalRiwayat':
                                      summaryHafalan.terakhirHafalan?.tanggal,
                                  'status':
                                      summaryHafalan.terakhirHafalan?.status,
                                },
                              );
                            }
                          : () {},
                      icon: Icon(
                        Icons.visibility_outlined,
                        size: 18,
                        color: hasLastHafalan ? Colors.white : Colors.grey[400],
                      ),
                      label: Text(
                        'Lihat Detail',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: hasLastHafalan
                              ? Colors.white
                              : Colors.grey[400],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasLastHafalan
                            ? Colors.deepPurpleAccent.withValues(alpha: 0.8)
                            : Colors.grey[200],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Hafalan Button
                  Expanded(
                    flex: 4,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          '/progres-hafalan',
                          arguments: {'santriId': summaryHafalan.id.toString()},
                        );
                      },
                      icon: Icon(
                        Icons.book_outlined,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Hafalan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
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
                      controller.summaryHafalanList.isEmpty
                  ? 'Santri tidak ditemukan di ${controller.getTahapanLabel(controller.level.value)}'
                  : 'Data santri akan muncul di sini',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
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
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
}
