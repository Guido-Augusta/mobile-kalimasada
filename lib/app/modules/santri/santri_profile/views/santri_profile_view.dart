import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/santri.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;

import '../../../ortu/detail_ortu/controllers/detail_ortu_controller.dart';
import '../controllers/santri_profile_controller.dart';

class SantriProfileView extends GetView<SantriProfileController> {
  const SantriProfileView({super.key});

  Santri get _dummySantri => Santri(
    id: 0,
    userId: 0,
    nama: 'Loading Name Placeholder',
    tahapHafalan: '',
    peringkat: 10,
    totalPoin: 100,
    createdAt: DateTime.now(),
    poinUpdatedAt: DateTime.now(),
    user: User(
      id: 0,
      email: 'placeholder@gmail.com',
      password: '',
      role: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    orangTua: [OrangTua(id: 0, nama: 'Nama Orang Tua', tipe: 'Ayah')],
    waliKelas: [
      WaliKelas(
        id: 0,
        nama: 'Nama Ustadz',
        nomorHp: '0',
        waliKelasTahap: 'Level 1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Obx(() {
        final santri = controller.santriDetail.value;

        if (controller.isLoading.value) {
          return Skeletonizer(
            enabled: true,
            child: _buildContent(context, _dummySantri),
          );
        }

        if (santri == null) {
          return _buildEmptyState(context);
        }

        return _buildContent(context, santri);
      }),
    );
  }

  RefreshIndicator _buildContent(BuildContext context, Santri santri) {
    return RefreshIndicator(
      onRefresh: () async => controller.getSantriDetail(),
      color: Colors.deepPurpleAccent,
      backgroundColor: Colors.white,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          _buildSliverHeader(context, santri),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildParentsSection(santri),
                const SizedBox(height: 24),
                _buildWaliKelasSection(santri),
                const SizedBox(height: 24),
                _buildChartSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // --- Header ---
  SliverAppBar _buildSliverHeader(BuildContext context, Santri santri) {
    return SliverAppBar(
      centerTitle: true,
      title: Skeletonizer(
        enabled: controller.isLoading.value,
        effect: ShimmerEffect(
          baseColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.4),
        ),
        child: Text(
          'Profil Santri',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      actions: [
        Skeletonizer(
          enabled: controller.isLoading.value,
          effect: ShimmerEffect(
            baseColor: Colors.white.withValues(alpha: 0.2),
            highlightColor: Colors.white.withValues(alpha: 0.4),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 22,
            ),
            tooltip: 'Pengaturan',
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ),
      ],
      expandedHeight: 260,
      pinned: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
                ),
              ),
            ),
            // Pattern Overlay (subtle circles)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Skeletonizer(
                  enabled: controller.isLoading.value,
                  effect: ShimmerEffect(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Avatar Image
                      Skeletonizer(
                        enabled: controller.isLoading.value,
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(santri.nama ?? ''),
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurpleAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          santri.nama ?? 'Nama tidak tersedia',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Badges
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTahapBadge(santri.tahapHafalan ?? ''),
                          _buildPointBadge(santri.totalPoin ?? 0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return words[0].substring(0, words[0].length > 1 ? 2 : 1).toUpperCase();
  }

  Color _getTahapColor(String tahap) {
    switch (tahap.toLowerCase()) {
      case 'level1':
        return Colors.green;
      case 'level2':
        return Colors.orange;
      case 'level3':
        return Colors.red;
      default:
        return Colors.white.withValues(alpha: 0.2);
    }
  }

  String getTahapLabel(String? tahap) {
    switch (tahap?.toLowerCase()) {
      case 'level1':
        return 'Level 1 - Juz 30';
      case 'level2':
        return 'Level 2 - Surah Pilihan';
      case 'level3':
        return 'Level 3 - Juz 1-29';
      default:
        return 'Belum ada tahap';
    }
  }

  Widget _buildTahapBadge(String tahap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
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
              color: _getTahapColor(tahap),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            getTahapLabel(tahap),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointBadge(int poin) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars_rounded, size: 14, color: Colors.amberAccent),
          const SizedBox(width: 6),
          Text(
            '$poin Poin',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- Common Card Builder ---
  Widget _buildModernCard({
    required String title,
    required IconData headerIcon,
    required Color headerColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: headerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(headerIcon, size: 18, color: headerColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          Padding(padding: const EdgeInsets.all(8.0), child: child),
        ],
      ),
    );
  }

  // --- Parents Section ---
  Widget _buildParentsSection(Santri santri) {
    return _buildModernCard(
      title: 'Informasi Orang Tua',
      headerIcon: Icons.family_restroom_rounded,
      headerColor: const Color(0xFF4F46E5),
      child: santri.orangTua.isEmpty
          ? _buildEmptyContent('Belum ada data orang tua')
          : Column(
              children: santri.orangTua.map((ortu) {
                return _buildListTile(
                  icon: Icons.person_outline_rounded,
                  iconColor: const Color(0xFF4F46E5),
                  title: ortu.nama ?? '-',
                  subtitle: ortu.tipe ?? '-',
                  onTap: () {
                    if (Get.isRegistered<DetailOrtuController>()) {
                      Get.delete<DetailOrtuController>();
                    }
                    Get.toNamed(
                      '/detail-ortu',
                      arguments: {'ortuId': ortu.id.toString()},
                    );
                  },
                );
              }).toList(),
            ),
    );
  }

  // --- Wali Kelas Section ---
  Widget _buildWaliKelasSection(Santri santri) {
    return _buildModernCard(
      title: 'Penanggung Jawab Kelas',
      headerIcon: Icons.school_rounded,
      headerColor: const Color(0xFF0D9488),
      child: santri.waliKelas.isEmpty
          ? _buildEmptyContent('Belum ada data wali kelas')
          : Column(
              children: santri.waliKelas.map((ustadz) {
                return _buildListTile(
                  icon: Icons.assignment_ind_outlined,
                  iconColor: const Color(0xFF0D9488),
                  title: ustadz.nama ?? '-',
                  subtitle: 'Wali Kelas',
                  onTap: () {
                    Get.toNamed(
                      '/detail-ustadz',
                      arguments: {'ustadzId': ustadz.id.toString()},
                    );
                  },
                  telepon: ustadz.nomorHp,
                );
              }).toList(),
            ),
    );
  }

  Widget _buildEmptyContent(String message) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.grey[400], size: 20),
          const SizedBox(width: 8),
          Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? telepon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF1E293B),
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (telepon != null && telepon.isNotEmpty) ...[
                _buildActionIcon(
                  icon: controller.isLoading.value
                      ? Icon(Icons.phone_rounded, size: 18, color: iconColor)
                      : SvgPicture.asset(
                          'assets/icons/whatsapp.svg',
                          width: 18,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFF25D366),
                            BlendMode.srcIn,
                          ),
                        ),
                  bgColor: const Color(0xFF25D366).withValues(alpha: 0.15),
                  onTap: () {
                    String formatted = telepon.startsWith('0')
                        ? '+62${telepon.substring(1)}'
                        : telepon;
                    launchUrl(Uri.parse("https://wa.me/$formatted"));
                  },
                ),
                const SizedBox(width: 8),
                _buildActionIcon(
                  icon: Icon(Icons.phone_rounded, size: 18, color: iconColor),
                  bgColor: iconColor.withValues(alpha: 0.15),
                  onTap: () => launchUrl(Uri.parse("tel:$telepon")),
                ),
              ] else ...[
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon({
    required Widget icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Skeletonizer(
        enabled: controller.isLoading.value,
        effect: ShimmerEffect(
          baseColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.4),
        ),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: icon,
        ),
      ),
    );
  }

  // --- Chart Section ---
  Widget _buildChartSection() {
    return _buildModernCard(
      title: 'Grafik Hafalan',
      headerIcon: Icons.insights_rounded,
      headerColor: const Color(0xFFEA580C),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 9,
                  child: Obx(
                    () => _buildDropdownButton(
                      value: controller.selectedChartType.value.name,
                      items: const [
                        DropdownMenuItem(
                          value: 'tambahHafalan',
                          child: Text('Hafalan'),
                        ),
                        DropdownMenuItem(
                          value: 'murajaah',
                          child: Text('Murajaah'),
                        ),
                        DropdownMenuItem(
                          value: 'tahsin',
                          child: Text('Tahsin'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == 'tambahHafalan') {
                          controller.selectedChartType.value =
                              ChartType.tambahHafalan;
                        } else if (val == 'murajaah') {
                          controller.selectedChartType.value =
                              ChartType.murajaah;
                        } else if (val == 'tahsin') {
                          controller.selectedChartType.value = ChartType.tahsin;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 9,
                  child: Obx(
                    () => _buildDropdownButton(
                      value: controller.selectedChartMode.value,
                      items: const [
                        DropdownMenuItem(value: 'ayat', child: Text('Ayat')),
                        DropdownMenuItem(
                          value: 'halaman',
                          child: Text('Halaman'),
                        ),
                      ],
                      onChanged: (val) {
                        controller.selectedChartMode.value = val!;
                        controller.getChart();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 7,
                  child: Obx(
                    () => _buildDropdownButton(
                      value: controller.range.value,
                      items: const [
                        DropdownMenuItem(value: '1w', child: Text('1 Mgg')),
                        DropdownMenuItem(value: '1m', child: Text('1 Bln')),
                        DropdownMenuItem(value: '3m', child: Text('3 Bln')),
                      ],
                      onChanged: (val) {
                        controller.range.value = val!;
                        controller.getChart();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildChartDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Color(0xFF64748B),
          ),
          style: GoogleFonts.poppins(
            color: const Color(0xFF334155),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildChartDisplay() {
    return Obx(() {
      if (controller.isLoadingChart.value) {
        return const SizedBox(
          height: 220,
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          ),
        );
      }

      if (controller.isChartError.value) {
        return Container(
          height: 220,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_rounded, size: 36, color: Colors.red[300]),
              const SizedBox(height: 8),
              Text(
                'Gagal memuat grafik',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => controller.getChart(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      if (controller.chart.value == null ||
          controller.chart.value!.data.isEmpty) {
        return SizedBox(
          height: 220,
          child: Center(
            child: Text(
              'Belum ada data untuk ditampilkan',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[500]),
            ),
          ),
        );
      }

      return Column(
        children: [
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY:
                    _calculateMaxY(
                      controller.chart.value!.data,
                      controller.selectedChartType.value,
                    ) *
                    1.2,
                minY: 0,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF1E293B),
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final date =
                          controller.chart.value!.data[group.x.toInt()].tanggal;
                      final day = date?.day.toString().padLeft(2, '0') ?? '';
                      final month =
                          date?.month.toString().padLeft(2, '0') ?? '';
                      final mode = controller.selectedChartMode.value == 'ayat'
                          ? 'Ayat'
                          : 'Halaman';
                      return BarTooltipItem(
                        '${rod.toY.toInt()} $mode\n',
                        GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '$day/$month',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[300],
                              fontSize: 10,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: _buildTitlesData(controller.chart.value!.data),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF1F5F9),
                    strokeWidth: 1.5,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: _buildBarGroups(
                  controller.chart.value!.data,
                  controller.selectedChartType.value,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            children: [
              _buildLegendItem('Hafalan', Colors.green),
              _buildLegendItem('Murajaah', Colors.orange),
              _buildLegendItem('Tahsin', Colors.blue),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<c.Datum> data,
    ChartType chartType,
  ) {
    return List.generate(data.length, (index) {
      final yValue =
          (chartType == ChartType.tambahHafalan
                  ? data[index].tambahHafalan ?? 0
                  : chartType == ChartType.murajaah
                  ? data[index].murajaah ?? 0
                  : data[index].tahsin ?? 0)
              .toDouble();

      final barColor = chartType == ChartType.tambahHafalan
          ? const Color(0xFF10B981)
          : chartType == ChartType.murajaah
          ? const Color(0xFFF59E0B)
          : const Color(0xFF3B82F6);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: yValue,
            color: barColor,
            width: controller.range.value == '1w'
                ? 14
                : controller.range.value == '1m'
                ? 8
                : 4,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(data, chartType) * 1.2,
              color: const Color(0xFFF1F5F9),
            ),
          ),
        ],
      );
    });
  }

  double _calculateMaxY(List<c.Datum> data, ChartType chartType) {
    if (data.isEmpty) return 10;
    int maxY = 5;
    for (var item in data) {
      int val = chartType == ChartType.tambahHafalan
          ? item.tambahHafalan ?? 0
          : chartType == ChartType.murajaah
          ? item.murajaah ?? 0
          : item.tahsin ?? 0;
      if (val > maxY) maxY = val;
    }
    return maxY.toDouble() + 1;
  }

  FlTitlesData _buildTitlesData(List<c.Datum> data) {
    int interval = data.length <= 7
        ? 1
        : data.length <= 14
        ? 2
        : data.length <= 21
        ? 3
        : (data.length / 7).ceil();
    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 32,
          maxIncluded: false,
          getTitlesWidget: (value, meta) => Text(
            value.toInt().toString(),
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index % interval != 0 || index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }
            final date = data[index].tanggal;
            if (date == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Settings & Edit Profile dialogs

  void _showSettingsBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Pengaturan Akun',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingsInfoTile(
              icon: Icons.edit_note_rounded,
              label: 'Profil',
              value: 'Edit Informasi Profil',
              isAccountAction: true,
              onTap: () {
                Get.back(); // close bottom sheet
                controller.namaC.text = controller.santriDetail.value!.nama!;
                _showEditProfileDialog();
              },
            ),
            Divider(color: Colors.grey[200], height: 16),
            _buildSettingsInfoTile(
              icon: Icons.lock_reset_rounded,
              label: 'Keamanan',
              value: 'Ubah Password Akun',
              isAccountAction: true,
              onTap: () {
                Get.back(); // close bottom sheet
                Get.toNamed('/change-password');
              },
            ),
            Divider(color: Colors.grey[200], height: 16),
            _buildSettingsInfoTile(
              icon: Icons.logout_rounded,
              label: 'Sesi',
              value: 'Keluar dari Aplikasi',
              isAccountAction: true,
              iconColor: Colors.redAccent,
              onTap: () {
                Get.back(); // close bottom sheet
                _showLogoutDialog(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSettingsInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool? isAccountAction,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.deepPurpleAccent).withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.deepPurpleAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (isAccountAction == true) ...[
              const SizedBox(width: 8),
              Center(
                child: Icon(
                  Icons.keyboard_arrow_right_rounded,
                  color: iconColor ?? Colors.deepPurpleAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.35,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
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
                      'Edit Profil',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pastikan data Anda benar',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Nama Lengkap',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          controller: controller.namaC,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nama Lengkap',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            fillColor: Colors.grey[50],
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
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
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
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
                          onPressed: controller.isSaveLoading.value
                              ? null
                              : () {
                                  if (controller.formKey.currentState!
                                      .validate()) {
                                    controller.updateProfileData(
                                      controller.namaC.text,
                                      controller.noHpC.text,
                                      controller.alamatC.text,
                                      controller.jenisKelaminC.text,
                                      controller.tanggalLahirC.text,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: controller.isSaveLoading.value
                                ? EdgeInsets.symmetric(vertical: 4)
                                : EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSaveLoading.value
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Transform.scale(
                                    scale: 0.8,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah anda yakin ingin logout?',
            style: GoogleFonts.poppins(),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Tidak',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoadingLogout.value
                    ? null
                    : () => controller.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoadingLogout.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Ya',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
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
                Icons.person_off_rounded,
                size: 48,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Data santri tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk refresh',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
