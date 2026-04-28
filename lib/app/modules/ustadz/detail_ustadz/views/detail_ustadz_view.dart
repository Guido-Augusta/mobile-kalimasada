import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/models/ustadz.dart';
import '../controllers/detail_ustadz_controller.dart';

class DetailUstadzView extends GetView<DetailUstadzController> {
  const DetailUstadzView({super.key});
  Ustadz get _dummyUstadz => Ustadz(
    id: 0,
    userId: 0,
    nama: 'Loading Name Placeholder',
    nomorHp: '081234567890',
    alamat: 'Jl. Contoh Alamat No. 123',
    jenisKelamin: 'L',
    fotoProfil: '',
    waliKelasTahap: 'Level1',
    user: User(
      id: 0,
      email: 'placeholder@email.com',
      password: '',
      role: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar:
            (!controller.isLoading.value && controller.ustadzData.value == null)
            ? AppBar(
                title: const Text(
                  'Detail Ustadz/ah',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFFF1F5F9),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
              )
            : null,
        body: Obx(() {
          final ustadz = controller.ustadzData.value;

          // Loading
          if (controller.isLoading.value) {
            return Skeletonizer(
              enabled: true,
              child: _buildContent(_dummyUstadz),
            );
          }
          // Data kosong
          if (ustadz == null) {
            return RefreshIndicator(
              onRefresh: () async {
                controller.fetchUstadzData();
              },
              color: Colors.deepPurpleAccent,
              backgroundColor: Colors.white,
              child: _buildEmptyState(context),
            );
          }

          return _buildContent(ustadz);
        }),
      ),
    );
  }

  RefreshIndicator _buildContent(Ustadz ustadz) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.fetchUstadzData(isRefresh: false);
      },
      color: Colors.deepPurpleAccent,
      backgroundColor: Colors.white,
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
                ustadz.jenisKelamin?.toLowerCase() == 'l'
                    ? 'Detail Ustadz'
                    : 'Detail Ustadzah',
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
            expandedHeight: 230,
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
                              // Profile Picture
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
                                  child: CachedNetworkImage(
                                    imageUrl: controller.getImageUrl(
                                      controller.fotoProfil.value,
                                    ),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
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
                                  ustadz.nama ?? 'Nama tidak tersedia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
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
                // Personal Information
                _buildPersonalInfoSection(ustadz),
                const SizedBox(height: 50), // Space for bottom buttons
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.person_off_rounded,
                size: 48,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data ustadz/ah tidak ditemukan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
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

  Widget _buildPersonalInfoSection(Ustadz ustadz) {
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
            icon: Icons.email_rounded,
            label: 'Email',
            value: ustadz.user?.email ?? '-',
          ),

          Divider(color: Colors.grey[200], height: 16),

          _buildInfoTile(
            icon: Icons.phone,
            label: 'No. Telepon',
            value: ustadz.nomorHp ?? '-',
            telepon: controller.isLoading.value ? null : ustadz.nomorHp,
          ),

          Divider(color: Colors.grey[200], height: 16),

          _buildInfoTile(
            icon: ustadz.jenisKelamin?.toLowerCase() == 'l'
                ? Icons.male
                : Icons.female,
            label: 'Jenis Kelamin',
            value: ustadz.jenisKelamin?.toLowerCase() == 'l'
                ? 'Laki-laki'
                : 'Perempuan',
          ),

          if (ustadz.waliKelasTahap != null) ...[
            Divider(color: Colors.grey[200], height: 16),
            _buildInfoTile(
              icon: FontAwesomeIcons.school,
              label: 'Penanggung Jawab Kelas',
              value: _getTahapLabel(ustadz.waliKelasTahap ?? ''),
            ),
          ],

          Divider(color: Colors.grey[200], height: 16),

          _buildInfoTile(
            icon: Icons.location_on,
            label: 'Alamat',
            value: ustadz.alamat ?? '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    String? telepon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
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
                ),
              ],
            ),
          ),
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
    );
  }

  String _getTahapLabel(String tahap) {
    switch (tahap) {
      case 'Level1':
        return 'Level 1 - Juz 30';
      case 'Level2':
        return 'Level 2 - Surah Pilihan';
      case 'Level3':
        return 'Level 3 - Juz 1-29';
      default:
        return 'Tahap tidak ditemukan';
    }
  }
}
