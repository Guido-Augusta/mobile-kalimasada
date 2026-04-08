import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_kalimasada/app/data/models/santri.dart';
import '../../../ortu/detail_ortu/controllers/detail_ortu_controller.dart';
import '../controllers/detail_santri_controller.dart';

class DetailSantriView extends GetView<DetailSantriController> {
  const DetailSantriView({super.key});

  Santri get _dummySantri => Santri(
    id: 0,
    userId: 0,
    nama: 'Loading Name Placeholder',
    nomorHp: '081234567890',
    noInduk: '123456789',
    alamat: 'Jl. Contoh Alamat',
    jenisKelamin: 'L',
    tanggalLahir: DateTime.now(),
    fotoProfil: '',
    tahapHafalan: 'Level3',
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
    orangTua: [
      OrangTua(id: 0, nama: 'Nama Orang Tua Placeholder', tipe: 'Ayah'),
    ],
    waliKelas: [
      WaliKelas(
        id: 0,
        nama: 'Nama Ustadz Placeholder',
        nomorHp: '0',
        waliKelasTahap: 'Level 1',
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Obx(() {
          final santri = controller.santriDetail.value;

          // Loading
          if (controller.isLoading.value) {
            return Skeletonizer(
              enabled: true,
              child: _buildContent(_dummySantri),
            );
          }
          // Empty Data
          if (santri == null) {
            return _buildEmptyState(context);
          }

          // Main Content
          return _buildContent(santri);
        }),
        bottomNavigationBar:
            (controller.santriDetail.value != null &&
                !controller.isLoading.value &&
                !controller.isAdmin)
            ? _buildBottomButtons()
            : null,
      ),
    );
  }

  RefreshIndicator _buildContent(Santri santri) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.getSantriDetail(controller.santriId);
      },
      child: CustomScrollView(
        slivers: [
          // Custom App Bar with Gradient Background
          SliverAppBar(
            centerTitle: true,
            title: Skeletonizer(
              enabled: controller.isLoading.value,
              effect: ShimmerEffect(
                baseColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.4),
              ),
              child: Text(
                'Detail Santri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            leading: Skeletonizer(
              enabled: controller.isLoading.value,
              effect: ShimmerEffect(
                baseColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.4),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              if (controller.isUstadz || controller.isAdmin)
                Skeletonizer(
                  enabled: controller.isLoading.value,
                  effect: ShimmerEffect(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: () {
                      _showEditTahapDialog();
                    },
                  ),
                ),
            ],
            expandedHeight: 260,
            pinned: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
                  ),
                ),
                child: Skeletonizer(
                  enabled: controller.isLoading.value,
                  effect: ShimmerEffect(
                    baseColor: Colors.white.withValues(alpha: 0.2),
                    highlightColor: Colors.white.withValues(alpha: 0.4),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Profile Section
                        const SizedBox(height: 40),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Profile Picture with Border
                              Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.2,
                                      ),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child:
                                      santri.fotoProfil != null &&
                                          santri.fotoProfil!.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: controller.getImageUrl(
                                            santri.fotoProfil!,
                                          ),
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.person,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Name
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(
                                  santri.nama ?? 'Nama tidak tersedia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Badges Wrap
                              Wrap(
                                direction: Axis.horizontal,
                                alignment: WrapAlignment.center,
                                runAlignment: WrapAlignment.center,
                                children: [
                                  // Tahap Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!controller.isLoading.value) ...[
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: _getTahapColor(
                                                santri.tahapHafalan!,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Text(
                                          getTahapLabel(santri.tahapHafalan),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (controller.isUstadz) ...[
                                    const SizedBox(width: 8),
                                    // Gender Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            santri.jenisKelamin
                                                        ?.toLowerCase() ==
                                                    'l'
                                                ? Icons.male
                                                : Icons.female,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            santri.jenisKelamin
                                                        ?.toLowerCase() ==
                                                    'l'
                                                ? 'Laki-laki'
                                                : 'Perempuan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // Point Badge
                                  if (controller.isOrtu ||
                                      controller.isAdmin) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star_rounded,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${santri.totalPoin} Poin',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats Cards
                if (controller.isUstadz) ...[
                  _buildStatsCards(santri),
                  const SizedBox(height: 18),
                ],

                // Personal Information
                _buildPersonalInfoSection(santri),

                const SizedBox(height: 18),

                // Parents Information
                _buildParentsInfoSection(santri),

                const SizedBox(height: 18),

                // Wali Kelas Information
                _buildWaliKelasSection(santri),

                const SizedBox(height: 18),

                // Grafik Hafalan
                _buildChartHafalanSection(santri),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  RefreshIndicator _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.getSantriDetail(controller.santriId);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height:
              MediaQuery.of(context).size.height -
              kToolbarHeight -
              MediaQuery.of(context).padding.top,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.person,
                  size: 48,
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data santri tidak ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tarik ke bawah untuk refresh',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTahapDialog() {
    controller.selectedTahap.value =
        controller.santriDetail.value?.tahapHafalan ?? 'Level1';
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ubah Tahap Hafalan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih tahap hafalan baru untuk santri ini',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Tahap Hafalan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Obx(
                        () => DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.selectedTahap.value.isEmpty
                                ? controller.santriDetail.value?.tahapHafalan
                                : controller.selectedTahap.value,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.expand_more_rounded,
                              color: Colors.deepPurple,
                            ),
                            iconSize: 24,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.selectedTahap.value = newValue;
                              }
                            },
                            items: [
                              _buildDropdownItem('Level1', 'Level 1 - Juz 30'),
                              _buildDropdownItem(
                                'Level2',
                                'Level 2 - Surah Pilihan',
                              ),
                              _buildDropdownItem(
                                'Level3',
                                'Level 3 - Juz 1-29',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
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
                                controller.updateTahapHafalan(
                                  controller.selectedTahap.value,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.deepPurpleAccent
                              .withValues(alpha: 0.7),
                        ),
                        child: controller.isSaveLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Simpan',
                                style: GoogleFonts.poppins(
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
    );
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
        return Colors.grey;
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

  Widget _buildStatsCards(Santri santri) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Total Poin
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.stars_rounded,
                        color: Colors.deepPurpleAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Poin',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${santri.totalPoin ?? 0}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
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
            ),

            VerticalDivider(
              color: Colors.grey[200],
              thickness: 1,
              width: 1,
              indent: 24,
              endIndent: 24,
            ),

            // Peringkat
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.orange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Peringkat',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '#${santri.peringkat ?? '-'}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection(Santri santri) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Pribadi',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoTile(
            icon: Icons.credit_card,
            label: 'No. Induk',
            value: santri.noInduk ?? '-',
          ),

          Divider(color: Colors.grey[200], height: 16),

          _buildInfoTile(
            icon: Icons.email,
            label: 'Email',
            value: santri.user?.email ?? '-',
          ),

          if (controller.isOrtu) ...[
            Divider(color: Colors.grey[200], height: 16),
            _buildInfoTile(
              icon: santri.jenisKelamin?.toLowerCase() == 'l'
                  ? Icons.male
                  : Icons.female,
              label: 'Jenis Kelamin',
              value: santri.jenisKelamin?.toLowerCase() == 'l'
                  ? 'Laki-laki'
                  : 'Perempuan',
            ),
          ],

          Divider(color: Colors.grey[200], height: 16),

          _buildInfoTile(
            icon: Icons.calendar_today_rounded,
            label: 'Tanggal Lahir',
            value: santri.tanggalLahir != null
                ? DateFormat(
                    'dd MMMM yyyy',
                    'id_ID',
                  ).format(santri.tanggalLahir!)
                : '-',
          ),

          Divider(color: Colors.grey[200], height: 16),

          _buildInfoTile(
            icon: Icons.phone,
            label: 'No. Telepon',
            value: () {
              if (santri.nomorHp == null) {
                return '-';
              } else if (santri.nomorHp!.isEmpty) {
                return '-';
              } else {
                return santri.nomorHp!;
              }
            }(),
            telepon: controller.isLoading.value ? null : santri.nomorHp,
          ),

          Divider(color: Colors.grey[200], height: 16),

          _buildInfoTile(
            icon: Icons.location_on,
            label: 'Alamat',
            value: santri.alamat ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildParentsInfoSection(Santri santri) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Orang Tua',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          () {
            if (santri.orangTua.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Belum ada data orang tua',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: santri.orangTua.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey[200], height: 16),
              itemBuilder: (context, index) {
                final orangTua = santri.orangTua[index];
                return _buildInfoTile(
                  icon: Icons.family_restroom_rounded,
                  label: orangTua.tipe ?? '-',
                  value: orangTua.nama ?? '-',
                  isGoToDetail: true,
                  ortuId: orangTua.id.toString(),
                  onTap: () {
                    if (Get.isRegistered<DetailOrtuController>()) {
                      Get.delete<DetailOrtuController>();
                    }
                    Get.toNamed(
                      '/detail-ortu',
                      arguments: {'ortuId': orangTua.id.toString()},
                    );
                  },
                );
              },
            );
          }(),
        ],
      ),
    );
  }

  Widget _buildWaliKelasSection(Santri santri) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penanggung Jawab Kelas',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Wali Kelas
          if (santri.waliKelas.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[400], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Belum ada data wali kelas',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: santri.waliKelas.length,
              separatorBuilder: (context, index) =>
                  Divider(color: Colors.grey[200], height: 16),
              itemBuilder: (context, index) {
                final waliKelas = santri.waliKelas[index];
                return _buildInfoTile(
                  icon: Icons.school,
                  label: 'PJ Kelas',
                  value: waliKelas.nama ?? '-',
                  isGoToDetail: true,
                  onTap: () {
                    Get.toNamed(
                      '/detail-ustadz',
                      arguments: {'ustadzId': waliKelas.id.toString()},
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildChartHafalanSection(Santri santri) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChartHeader(),
          const SizedBox(height: 16),
          _buildChartFilters(),
          const SizedBox(height: 16),
          _buildChart(),
        ],
      ),
    );
  }

  Row _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Grafik Hafalan',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
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
                  vertical: 6,
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

  Widget _buildChartFilters() {
    return Row(
      children: [
        Expanded(
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
                      tooltipBorderRadius: BorderRadius.circular(6),
                      tooltipBorder: BorderSide(color: Colors.grey[200]!),
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

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    String? telepon,
    bool? isGoToDetail,
    String? ortuId,
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
                color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.deepPurpleAccent, size: 20),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (isGoToDetail == true) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.keyboard_arrow_right_rounded,
                color: Colors.deepPurpleAccent,
              ),
            ],

            if (telepon != null && telepon.isNotEmpty)
              Row(
                children: [
                  const SizedBox(width: 8),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/whatsapp.svg',
                      width: 20,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFF25D366),
                        BlendMode.srcIn,
                      ),
                    ),
                    onPressed: () {
                      String formattedNomor = telepon;
                      if (telepon.startsWith('0')) {
                        formattedNomor = '+62${telepon.substring(1)}';
                      }

                      final whatsappUrl = "https://wa.me/$formattedNomor";
                      launchUrl(Uri.parse(whatsappUrl));
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF25D366,
                      ).withValues(alpha: 0.1),
                      shape: const CircleBorder(),
                    ),
                  ),

                  const SizedBox(width: 4),

                  IconButton(
                    icon: const Icon(
                      Icons.phone,
                      size: 18,
                      color: Colors.deepPurpleAccent,
                    ),
                    onPressed: () {
                      final phoneUrl = "tel:$telepon";
                      launchUrl(Uri.parse(phoneUrl));
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent.withValues(
                        alpha: 0.1,
                      ),
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.history),
                label: Text(
                  'Riwayat',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[50],
                  foregroundColor: Colors.orange,
                  shadowColor: Colors.transparent,
                  side: const BorderSide(color: Colors.orange),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Get.toNamed(
                    '/riwayat-hafalan',
                    arguments: {'santriId': controller.santriId},
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.book_rounded),
                label: Text(
                  'Hafalan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: const Color(0xFF10B981),
                  shadowColor: Colors.transparent,
                  side: const BorderSide(color: Color(0xFF10B981)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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
      ),
    );
  }
}
