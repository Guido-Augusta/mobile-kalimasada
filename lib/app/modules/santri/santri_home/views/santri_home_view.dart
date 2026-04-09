import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../routes/app_pages.dart';
import '../controllers/santri_home_controller.dart';

class SantriHomeView extends GetView<SantriHomeController> {
  const SantriHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(backgroundColor: Color(0xFFF1F5F9), toolbarHeight: 0),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            controller.getSantri();
          },
          child: ListView(
            padding: const EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              _buildWelcomeCard(context),
              const SizedBox(height: 25),
              _buildFeatureCards(context),
              const SizedBox(height: 25),
              _buildChartSection(),
              const SizedBox(height: 25),
              _buildIslamicDecoration(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: CachedNetworkImageProvider(
                controller.getImageUrl(controller.fotoProfil.value),
              ),
              onBackgroundImageError: (_, _) {
                controller.fotoProfil.value =
                    'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg';
              },
              child:
                  controller.fotoProfil.value.isEmpty ||
                      controller.fotoProfil.value == ''
                  ? Icon(Icons.person, size: 28, color: Colors.deepPurpleAccent)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamualaikum,',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Obx(
                () => Skeletonizer(
                  enabled:
                      controller.isLoading.value ||
                      controller.santri.value?.nama == null,
                  child: Text(
                    controller.isLoading.value ||
                            controller.santri.value?.nama == null
                        ? 'Loading Name'
                        : (controller.santri.value?.nama ?? ''),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      // color: Colors.deepPurple[800],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
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
                        onPressed: () {
                          Get.back();
                        },
                        child: Text(
                          'Tidak',
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
                        ),
                      ),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoadingLogout.value
                              ? null
                              : () {
                                  controller.logout();
                                },
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
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.logout_rounded, color: Colors.red, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dashboard Santri',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Aplikasi Tahfidz Kalimasada',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicDecoration(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.teal.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mosque, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalimasada: Tahfidz App',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Menuntut ilmu dengan penuh keikhlasan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'طَلَبُ الْعِلْمِ فَرِيْضَةٌ عَلَى كُلِّ مُسْلِمٍ',
              style: GoogleFonts.amiri(
                fontSize: 20,
                color: Colors.green[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Menuntut ilmu itu wajib atas setiap Muslim',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitur Utama',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            // color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 14),
        InkWell(
          onTap: () {
            Get.toNamed(
              Routes.PROGRES_HAFALAN,
              arguments: {'santriId': controller.santri.value?.id.toString()},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.menu_book_rounded,
                    color: Colors.deepPurple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progres Hafalan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lihat progres hafalan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withValues(alpha: 0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.deepPurpleAccent,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        InkWell(
          onTap: () {
            Get.toNamed(
              Routes.RIWAYAT_HAFALAN,
              arguments: {'santriId': controller.santri.value?.id.toString()},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.history, color: Colors.orange, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Riwayat Hafalan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple[800],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lihat riwayat hafalan',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.black.withValues(alpha: 0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.deepPurpleAccent,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Grafik Hafalan',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            // color: Colors.deepPurple[800],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 10, right: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Obx(
            () => AbsorbPointer(
              absorbing: controller.isLoadingChart.value,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.range.value,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.grey,
                  ),
                  isDense: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  dropdownColor: Colors.white,
                  items: [
                    _buildDropdownItem('1w', '1 Minggu'),
                    _buildDropdownItem('1m', '1 Bulan'),
                    _buildDropdownItem('3m', '3 Bulan'),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.range.value = newValue;
                      controller.getChart();
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
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
      ),
    );
  }

  Widget _buildChartSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChartHeader(),
        const SizedBox(height: 16),
        _buildChartFilters(),
        const SizedBox(height: 16),
        _buildChart(),
      ],
    );
  }

  Widget _buildChartFilters() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Obx(
            () => _buildDropdown(
              value: controller.selectedChartMode.value,
              items: const [
                DropdownMenuItem(value: 'ayat', child: Text('Ayat')),
                DropdownMenuItem(value: 'halaman', child: Text('Halaman')),
              ],
              onChanged: (val) {
                controller.selectedChartMode.value = val!;
                controller.getChart();
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
          child: Obx(
            () => _buildDropdown(
              value: controller.selectedChartType.value.name,
              items: const [
                DropdownMenuItem(
                  value: 'tambahHafalan',
                  child: Text('Tambah Hafalan'),
                ),
                DropdownMenuItem(value: 'murajaah', child: Text('Murajaah')),
                DropdownMenuItem(value: 'tahsin', child: Text('Tahsin')),
              ],
              onChanged: (val) {
                switch (val) {
                  case 'tambahHafalan':
                    controller.selectedChartType.value =
                        ChartType.tambahHafalan;
                    break;
                  case 'murajaah':
                    controller.selectedChartType.value = ChartType.murajaah;
                    break;
                  case 'tahsin':
                    controller.selectedChartType.value = ChartType.tahsin;
                    break;
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.deepPurple,
            size: 20,
          ),
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          isDense: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoadingChart.value) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (controller.chart.value == null ||
            controller.chart.value!.data.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                'Tidak ada data hafalan untuk ditampilkan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 250,
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
                  groupsSpace: 16,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (group) => Colors.white,
                      tooltipPadding: const EdgeInsets.all(8),
                      tooltipMargin: 8,
                      fitInsideVertically: true,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = controller
                            .chart
                            .value!
                            .data[group.x.toInt()]
                            .tanggal;
                        final day = date?.day.toString().padLeft(2, '0') ?? '';
                        final month =
                            date?.month.toString().padLeft(2, '0') ?? '';
                        final year = date?.year.toString().substring(2) ?? '';
                        final modeLabel =
                            controller.selectedChartMode.value == 'ayat'
                            ? 'Ayat'
                            : 'Halaman';
                        return BarTooltipItem(
                          '${rod.toY.toInt()} $modeLabel\n$day/$month/$year',
                          GoogleFonts.poppins(
                            color: Colors.deepPurple,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: _buildTitlesData(controller.chart.value!.data),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 2,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(color: Colors.grey[200], strokeWidth: 1);
                    },
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  barGroups: _buildBarGroups(
                    controller.chart.value!.data,
                    controller.selectedChartType.value,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        );
      }),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    List<c.Datum> data,
    ChartType chartType,
  ) {
    return List.generate(
      data.length,
      (index) => BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY:
                (chartType == ChartType.tambahHafalan
                        ? (data[index].tambahHafalan ?? 0)
                        : chartType == ChartType.murajaah
                        ? (data[index].murajaah ?? 0)
                        : (data[index].tahsin ?? 0))
                    .toDouble(),
            color: chartType == ChartType.tambahHafalan
                ? const Color(0xFF10B981)
                : chartType == ChartType.murajaah
                ? Colors.orangeAccent
                : Colors.blueAccent[700]!,
            width: controller.range.value == '1w'
                ? 12
                : controller.range.value == '1m'
                ? 8
                : 4,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY(List<c.Datum> data, ChartType chartType) {
    if (data.isEmpty) return 10;

    int maxY = 5; // Default minimum value
    for (var item in data) {
      if (chartType == ChartType.tambahHafalan) {
        if (item.tambahHafalan != null && item.tambahHafalan! > maxY) {
          maxY = item.tambahHafalan!;
        }
      } else if (chartType == ChartType.murajaah) {
        if (item.murajaah != null && item.murajaah! > maxY) {
          maxY = item.murajaah!;
        }
      } else {
        if (item.tahsin != null && item.tahsin! > maxY) {
          maxY = item.tahsin!;
        }
      }
    }
    return maxY.toDouble() + 1; // Add some padding
  }

  FlTitlesData _buildTitlesData(List<c.Datum> data) {
    // Calculate interval based on number of data points
    int interval;
    if (data.length <= 7) {
      interval = 1;
    } else if (data.length <= 14) {
      interval = 2;
    } else if (data.length <= 21) {
      interval = 3;
    } else {
      interval = (data.length / 7).ceil();
    }

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1, // Set interval to 1 to show all titles
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            // Only show title if the index is a multiple of our calculated interval
            if (index % interval != 0) {
              return const SizedBox.shrink(); // Return empty widget for non-interval indices
            }
            if (index < 0 || index >= data.length) {
              return const SizedBox.shrink();
            }
            final date = data[index].tanggal;
            if (date == null) return const SizedBox.shrink();

            // Format date as day/month
            final day = date.day.toString().padLeft(2, '0');
            final month = date.month.toString().padLeft(2, '0');
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '$day/$month',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: false,
          interval: 3,
          maxIncluded: false,
          minIncluded: false,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 28,
      runSpacing: 8,
      children: [
        _buildLegendItem('Hafalan', const Color(0xFF10B981)),
        _buildLegendItem('Murajaah', Colors.orangeAccent),
        _buildLegendItem('Tahsin', Colors.blueAccent[700]!),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
