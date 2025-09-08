import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/ustadz_profile_controller.dart';

class UstadzProfileView extends GetView<UstadzProfileController> {
  const UstadzProfileView({super.key});

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String value,
    int maxline,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.deepPurpleAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: maxline,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.deepPurpleAccent.shade700,
                    Colors.deepPurpleAccent.shade200,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Column(
                  children: [
                    Text(
                      'Profil Saya',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 40),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () {
                        // TODO: Implement camera functionality
                        Get.snackbar(
                          'Info',
                          'Fitur ini akan segera tersedia',
                          colorText: Colors.white,
                          backgroundColor: Colors.deepPurpleAccent,
                        );
                      },
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Obx(
                              () => CircleAvatar(
                                radius: 50,
                                backgroundImage: NetworkImage(
                                  controller.fotoProfil.value,
                                ),
                                onBackgroundImageError:
                                    (exception, stackTrace) {
                                      // Handle image loading error
                                    },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.deepPurpleAccent,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Text(
                        controller.ustadzData.value?.nama ?? '',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_border_purple500_rounded,
                                  color: Colors.deepPurpleAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  controller.ustadzData.value?.tingkatan ?? '',
                                  style: GoogleFonts.poppins(
                                    color: Colors.deepPurpleAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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

            // Profile Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Info Cards
                  Obx(
                    () => Column(
                      children: [
                        _buildInfoCard(
                          Icons.email_outlined,
                          'Email',
                          controller.ustadzData.value?.user?.email ?? '',
                          1,
                        ),
                        _buildInfoCard(
                          Icons.phone_outlined,
                          'Nomor HP',
                          controller.ustadzData.value?.nomorHp ?? '',
                          1,
                        ),
                        _buildInfoCard(
                          Icons.person_outline,
                          'Jenis Kelamin',
                          controller.ustadzData.value?.jenisKelamin == 'L'
                              ? 'Laki-laki'
                              : 'Perempuan',
                          1,
                        ),
                        _buildInfoCard(
                          Icons.location_on_outlined,
                          'Alamat',
                          controller.ustadzData.value?.alamat ??
                              'Alamat tidak ditemukan',
                          5,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // controller.navigateToEditProfile();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.edit, size: 20),
                          label: Text(
                            'Edit Profil',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // controller.logout();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.logout, size: 20),
                          label: Text(
                            'Logout',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
