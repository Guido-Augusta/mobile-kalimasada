import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../controllers/detail_riwayat_hafalan_controller.dart';

class DetailRiwayatHafalanView extends GetView<DetailRiwayatHafalanController> {
  const DetailRiwayatHafalanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Detail Riwayat Hafalan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.deepPurpleAccent,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        final isAyatMode = controller.isAyatMode;
        final hasData = isAyatMode
            ? controller.detailRiwayatAyat.value != null
            : controller.detailRiwayatHalaman.value != null;

        if (!hasData) {
          return LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: () async => controller.getDetailRiwayatHafalan(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.book_outlined,
                            size: 48,
                            color: Colors.deepPurpleAccent.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Data tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tarik ke bawah untuk refresh',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        final dynamic detailData = isAyatMode
            ? controller.detailRiwayatAyat.value!.data
            : controller.detailRiwayatHalaman.value!.data;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header Card
            _buildHeaderCard(detailData, isAyatMode),

            // Detail Information
            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white,
                elevation: 1,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailItem(
                        Icons.person_rounded,
                        'Ustadz',
                        detailData.ustadz?.nama ?? '-',
                      ),

                      if (detailData.status?.toLowerCase() ==
                          'tambahhafalan') ...[
                        const SizedBox(height: 12),
                        _buildDetailItem(
                          Icons.star_rounded,
                          'Total Poin',
                          detailData.totalPoin?.toString() ?? '-',
                        ),
                      ],
                      const SizedBox(height: 12),
                      if (!isAyatMode &&
                          detailData.surah != null &&
                          (detailData.surah as List).isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF6B46C1,
                                ).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                size: 16,
                                color: Color(0xFF6B46C1),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daftar Surah',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: TextEditingController(
                                      text: (detailData.surah as List)
                                          .map((s) => s.namaLatin ?? '')
                                          .join(', '),
                                    ),
                                    maxLines: null,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                          width: 1,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[800],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showCatatanDialog(detailData.catatan ?? ''),
                          icon: const Icon(Icons.note_alt_outlined),
                          label: const Text('Lihat Catatan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Ayat List Header
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Rincian Ayat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),

            // Ayat List
            if (detailData.daftarAyat == null || detailData.daftarAyat.isEmpty)
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
                          Icons.format_list_numbered_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada ayat',
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  final ayat = detailData.daftarAyat[index];

                  bool showSurahDivider = false;
                  if (!isAyatMode && ayat.surah != null) {
                    if (index == 0) {
                      showSurahDivider = true;
                    } else {
                      final prevAyat = detailData.daftarAyat[index - 1];
                      if (ayat.surah!.id != prevAyat.surah?.id) {
                        showSurahDivider = true;
                      }
                    }
                  }

                  Widget ayatCard = Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.white,
                    elevation: 1,
                    shadowColor: Colors.black.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Ayat Number and Surah
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${ayat.nomorAyat}',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (!isAyatMode && ayat.surah != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      ayat.surah!.namaLatin ?? '-',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Row(
                                children: [
                                  if (ayat.kualitas != null &&
                                      (ayat.kualitas as String).isNotEmpty)
                                    _buildKualitasBadge(ayat.kualitas!),
                                  if (ayat.keterangan != null &&
                                      (ayat.keterangan as String)
                                          .isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    _buildKeteranganBadge(ayat.keterangan!),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Arabic Text
                          if (ayat.arab != null && ayat.arab!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  ayat.arab!,
                                  style: GoogleFonts.amiri(
                                    fontSize: 24,
                                    height: 2.5,
                                  ),
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ),

                          // Latin Text
                          if (ayat.latin != null && ayat.latin!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                ayat.latin!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                              ),
                            ),

                          // Translation
                          if (ayat.terjemah != null &&
                              ayat.terjemah!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurpleAccent.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  ayat.terjemah!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );

                  if (showSurahDivider) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (index > 0) const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.deepPurple[100],
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple[50],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.deepPurple[100]!,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurpleAccent
                                              .withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${ayat.surah!.id}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepPurple[700],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        ayat.surah!.namaLatin ?? '-',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.deepPurple[100],
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ayatCard,
                      ],
                    );
                  }

                  return ayatCard;
                }, childCount: detailData.daftarAyat.length),
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      }),
    );
  }

  SliverToBoxAdapter _buildHeaderCard(dynamic detailData, bool isAyatMode) {
    String titleValue = '-';

    if (isAyatMode) {
      titleValue = detailData.surah?.namaLatin ?? '-';
    } else {
      titleValue = 'Juz ${detailData.juz ?? '-'}';
    }

    String infoTitle1 = isAyatMode ? 'Ayat' : 'Halaman';
    String infoValue1 = '-';
    if (isAyatMode && detailData.rangeAyat != null) {
      infoValue1 =
          'Ayat ${detailData.rangeAyat!.awal} - ${detailData.rangeAyat!.akhir}';
    } else if (!isAyatMode && detailData.rangeHalaman != null) {
      infoValue1 =
          'Hal. ${detailData.rangeHalaman!.awal} - ${detailData.rangeHalaman!.akhir}';
    }

    return SliverToBoxAdapter(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isAyatMode
                              ? Icons.auto_stories_rounded
                              : Icons.menu_book_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isAyatMode)
                              Text(
                                'Surah',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            Text(
                              titleValue,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isAyatMode ? 16 : 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        detailData.tanggal != null
                            ? DateFormat(
                                'dd MMM yyyy',
                                'id_ID',
                              ).format(detailData.tanggal!)
                            : '-',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
                _buildInfoCard(infoTitle1, infoValue1, flex: 7),
                const SizedBox(width: 12),
                _buildInfoCard(
                  'Status',
                  _getStatusText(detailData.status),
                  flex: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKualitasBadge(String kualitas) {
    Color kualitasBgColor = Colors.blue[50]!;
    Color kualitasTextColor = Colors.blue[700]!;

    final k = kualitas.toLowerCase().replaceAll(' ', '');
    if (k == 'kurang') {
      kualitasBgColor = Colors.red[50]!;
      kualitasTextColor = Colors.red[700]!;
    } else if (k == 'cukup') {
      kualitasBgColor = Colors.orange[50]!;
      kualitasTextColor = Colors.orange[700]!;
    } else if (k == 'baik') {
      kualitasBgColor = Colors.teal[50]!;
      kualitasTextColor = Colors.teal[700]!;
    } else if (k == 'sangatbaik') {
      kualitasBgColor = Colors.blue[50]!;
      kualitasTextColor = Colors.blue[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kualitasBgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kualitas,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: kualitasTextColor,
        ),
      ),
    );
  }

  Widget _buildKeteranganBadge(String keterangan) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: keterangan.toLowerCase() == 'lanjut'
            ? Colors.green[50]
            : Colors.orange[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: keterangan.toLowerCase() == 'lanjut'
              ? Colors.green[200]!
              : Colors.orange[200]!,
        ),
      ),
      child: Text(
        keterangan,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: keterangan.toLowerCase() == 'lanjut'
              ? Colors.green[700]
              : Colors.orange[700],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
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
            Text(
              title,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF6B46C1).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF6B46C1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color getStatusColor(String? status) {
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
        return 'Tambah Hafalan';
      default:
        return status ?? '-';
    }
  }

  void _showCatatanDialog(String catatan) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.note_alt_outlined, color: Colors.deepPurple, size: 24),
            SizedBox(width: 8),
            Text(
              'Catatan Hafalan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 300),
          child: TextField(
            controller: TextEditingController(text: catatan),
            maxLines: null,
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Tidak ada catatan',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.all(16),
            ),
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
            child: const Text('Tutup'),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
