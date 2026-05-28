import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/models/santri.dart' as s;
import '../../../../widgets/islamic_decoration.dart';
import '../../../../widgets/welcome_card.dart';
import '../controllers/ortu_home_controller.dart';

class OrtuHomeView extends GetView<OrtuHomeController> {
  const OrtuHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => controller.loadHomeData(isRefresh: true),
          color: Colors.deepPurpleAccent,
          backgroundColor: Colors.white,
          child: ListView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              _buildHeader(context),
              const SizedBox(height: 30),
              const WelcomeCard(
                title: 'Dashboard Orang Tua',
                subtitle: 'Aplikasi Tahfidz Kalimasada',
                titleFontSize: 17,
              ),
              const SizedBox(height: 25),
              const IslamicDecoration(),
              const SizedBox(height: 25),
              _buildChildrenListHeader(),
              const SizedBox(height: 15),
              _buildSearchBar(),
              const SizedBox(height: 14),
              _buildChildrenList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildProfilePicture(context),
        const SizedBox(width: 12),
        Expanded(child: _buildWelcomeText()),
        const SizedBox(width: 4),
        _buildLogoutButton(context),
      ],
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    return Obx(
      () => Skeletonizer(
        enabled: controller.isLoading.value,
        child: GestureDetector(
          onTap: () {
            if (controller.fotoProfil.value != '' &&
                controller.fotoProfil.value != 'default.png') {
              FullscreenImageViewer.open(
                context: context,
                child: Hero(
                  tag: 'profile_photo',
                  child: CachedNetworkImage(
                    imageUrl: controller.getImageUrl(
                      controller.fotoProfil.value,
                    ),
                    fit: BoxFit.contain,
                  ),
                ),
              );
            }
          },
          child: Hero(
            tag: 'profile_photo',
            child: CachedNetworkImage(
              imageUrl: controller.getImageUrl(controller.fotoProfil.value),
              imageBuilder: (context, imageProvider) => CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                backgroundImage: imageProvider,
              ),
              placeholder: (context, url) =>
                  CircleAvatar(radius: 28, backgroundColor: Colors.grey[300]),
              errorWidget: (context, url, error) => CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey[200],
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: Colors.deepPurpleAccent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
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
                controller.ortu.value?.nama == null,
            child: Text(
              (controller.isLoading.value ||
                      controller.ortu.value?.nama == null)
                  ? 'Loading Name'
                  : (controller.ortu.value?.nama ?? ''),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(10),
          child: Icon(Icons.logout_rounded, color: Colors.red, size: 24),
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

  Widget _buildChildrenListHeader() {
    return Text(
      'Daftar Anak',
      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildChildrenList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingChildren.value) {
        return _buildLoadingIndicator();
      }

      if (controller.childrenList.isEmpty) {
        return _buildEmptyState(context);
      }

      return Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.childrenList.length,
            itemBuilder: (context, index) {
              return _buildSantriCard(controller.childrenList[index]);
            },
          ),
          _buildLoadMoreIndicator(),
        ],
      );
    });
  }

  Widget _buildSantriCard(s.Santri child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed('/detail-santri', arguments: child.id.toString());
          },
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    _buildAvatar(child.nama),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            child.nama ?? 'Nama tidak tersedia',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildTahapBadge(child.tahapHafalan),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey[300],
                      size: 24,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'Riwayat',
                        icon: Icons.history_rounded,
                        color: Colors.orange,
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Get.toNamed(
                            '/riwayat-hafalan',
                            arguments: {'santriId': child.id.toString()},
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        label: 'Hafalan',
                        icon: Icons.book_rounded,
                        color: const Color(0xFF10B981),
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          Get.toNamed(
                            '/progres-hafalan',
                            arguments: {'santriId': child.id.toString()},
                          );
                        },
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

  Widget _buildEmptyState(BuildContext context) {
    final isSearching = controller.appliedSearchQuery.value.isNotEmpty;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.25,
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
                isSearching ? Icons.search_off_rounded : Icons.people_rounded,
                size: 48,
                color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isSearching
                  ? 'Hasil pencarian tidak ditemukan'
                  : 'Belum Ada Data Anak',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Coba gunakan kata kunci lain'
                  : 'Tarik ke bawah untuk refresh',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: CircularProgressIndicator(color: Colors.deepPurpleAccent),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        controller: controller.searchController,
        onChanged: (value) {
          controller.searchQuery.value = value;
        },
        decoration: InputDecoration(
          hintText: 'Cari nama anak...',
          hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchQuery.value = '';
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  // Modern Badge Builder
  Widget _buildTahapBadge(String? tahap) {
    final color = _getTahapColor(tahap);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        _getTahapLabel(tahap),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // Modern Action Button Builder for Santri Card
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        highlightColor: color.withValues(alpha: 0.2),
        splashColor: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        return 'Level 1 - Juz 30';
      case 'level2':
        return 'Level 2 - Surah Pilihan';
      case 'level3':
        return 'Level 3 - Juz 1-29';
      default:
        return 'Tahap ?';
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length > 1 ? 2 : 1).toUpperCase();
  }

  Widget _buildAvatar(String? name) {
    final initials = _getInitials(name);
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.deepPurpleAccent.withValues(alpha: 0.08),
        border: Border.all(
          color: Colors.deepPurpleAccent.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: GoogleFonts.poppins(
            color: Colors.deepPurpleAccent,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
