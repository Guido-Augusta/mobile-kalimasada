import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/detail_ortu_controller.dart';

class DetailOrtuView extends GetView<DetailOrtuController> {
  const DetailOrtuView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: controller.ortuDetail.value == null
            ? AppBar(
                title: const Text(
                  'Detail Orang Tua',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.deepPurpleAccent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              )
            : null,
        body: Obx(() {
          final ortu = controller.ortuDetail.value;

          // Loading
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }
          // Empty Data
          if (ortu == null) {
            return _buildEmptyState(context);
          }

          // Main Content
          return _buildContent(ortu);
        }),
      ),
    );
  }

  RefreshIndicator _buildContent(Ortu ortu) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.getOrtuDetail(controller.ortuId!);
      },
      child: CustomScrollView(
        slivers: [
          // Custom App Bar with Gradient Background
          SliverAppBar(
            centerTitle: true,
            title: Text(
              controller.ortuDetail.value?.tipe?.toLowerCase() == 'ayah' ||
                      controller.ortuDetail.value?.tipe?.toLowerCase() == 'ibu'
                  ? 'Detail Orang Tua'
                  : 'Detail Wali',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),

            expandedHeight: 280,
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
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
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
                                ortu.nama ?? 'Nama tidak tersedia',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Badges Row
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      ortu.user?.email ??
                                          'Email tidak tersedia',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
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

          // Main Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Action Cards
                // _buildActionSection(ortu),
                // const SizedBox(height: 16),
                // Personal Information
                _buildPersonalInfoSection(ortu),
                const SizedBox(height: 50), // Space for bottom buttons
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Center _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  RefreshIndicator _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        controller.getOrtuDetail(controller.ortuId!);
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
                'Data tidak ditemukan',
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

  Widget _buildPersonalInfoSection(Ortu ortu) {
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoTile(
            icon: Icons.phone,
            label: 'No. Telepon',
            value: ortu.nomorHp ?? 'Tidak ada data',
            telepon: ortu.nomorHp,
          ),

          const SizedBox(height: 12),

          _buildInfoTile(
            icon: Icons.person,
            label: 'Peran',
            value: ortu.tipe ?? 'Tidak ada data',
          ),

          const SizedBox(height: 12),

          _buildInfoTile(
            icon: ortu.jenisKelamin?.toLowerCase() == 'l'
                ? Icons.male
                : Icons.female,
            label: 'Jenis Kelamin',
            value: ortu.jenisKelamin?.toLowerCase() == 'l'
                ? 'Laki-laki'
                : 'Perempuan',
          ),

          const SizedBox(height: 12),

          _buildInfoTile(
            icon: Icons.location_on,
            label: 'Alamat',
            value: ortu.alamat ?? 'Tidak ada data',
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
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
}
