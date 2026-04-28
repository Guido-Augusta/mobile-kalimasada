import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/daftar_ortu.dart';
import '../controllers/daftar_ortu_controller.dart';

class DaftarOrtuView extends GetView<DaftarOrtuController> {
  const DaftarOrtuView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Daftar Orang Tua',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: Obx(
        () => Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: controller.isFabVisible.value
                ? Offset.zero
                : const Offset(2, 0), // geser ke kanan
            child: FloatingActionButton(
              onPressed: () {
                Get.toNamed('/tambah-ortu');
              },
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            controller.fetchData();
          },
          color: Colors.deepPurpleAccent,
          backgroundColor: Colors.white,
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (controller.isFabVisible.value) {
                  controller.isFabVisible.value = false;
                }
              } else if (notification.direction == ScrollDirection.forward) {
                if (!controller.isFabVisible.value) {
                  controller.isFabVisible.value = true;
                }
              }
              return true;
            },
            child: ListView(
              controller: controller.scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                // Search Bar
                _buildSearchBar(),
  
                // Student List
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.searchQuery.value.isEmpty) {
                    return _buildLoadingIndicator();
                  } else if (controller.ortuList.isEmpty) {
                    return _buildEmptyState();
                  } else if (controller.searchQuery.value.isNotEmpty &&
                      controller.ortuList.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                    itemCount:
                        controller.ortuList.length +
                        (controller.hasMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= controller.ortuList.length) {
                        return _buildLoadMoreIndicator();
                      }
                      final ortu = controller.ortuList[index];
                      return _buildOrtuCard(ortu);
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
        child: Obx(
          () => TextField(
            controller: controller.searchController,
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari orang tua...',
              hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
              suffixIcon: controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: () {
                        controller.searchQuery.value = '';
                        controller.searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
        Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Tidak ada data orang tua',
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.searchQuery.value.isNotEmpty &&
                    controller.ortuList.isEmpty
                ? 'Orang tua tidak ditemukan'
                : 'Tarik ke bawah untuk refresh',
            style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
          ),
        ),
      ],
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
          const SizedBox(height: 100),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data...',
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildOrtuCard(Datum ortu) {
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
            Get.toNamed(
              '/detail-ortu',
              arguments: {'ortuId': ortu.id.toString()},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[100]!, width: 2),
                  ),
                  child: ClipOval(
                    child:
                        ortu.fotoProfil != null && ortu.fotoProfil!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: controller.getImageUrl(ortu.fotoProfil!),
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                            placeholder: (context, url) => Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.grey[400],
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              size: 28,
                              color: Colors.grey[400],
                            ),
                          )
                        : Icon(Icons.person, size: 28, color: Colors.grey[400]),
                  ),
                ),
                const SizedBox(width: 14),

                // Info Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ortu.nama ?? 'Nama tidak tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ortu.user?.email ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ortu.tipe ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Admin Menu Actions
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  surfaceTintColor: Colors.transparent,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  offset: const Offset(0, 40),
                  elevation: 4,
                  shadowColor: Colors.black.withValues(alpha: 0.2),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: Colors.orange[600],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Edit Profil',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.red[600],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Hapus Akun',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Get.toNamed(
                        '/edit-ortu',
                        arguments: {'ortuId': ortu.id.toString()},
                      );
                    } else if (value == 'delete') {
                      _showDeleteAccountDialog(Get.context!, ortu);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> _showDeleteAccountDialog(BuildContext context, Datum ortu) {
    return showDialog(
      context: context,
      builder: (context) {
        String roleLabel = 'akun';
        if (ortu.tipe?.toLowerCase() == 'ayah') {
          roleLabel = 'akun Ayah';
        } else if (ortu.tipe?.toLowerCase() == 'ibu') {
          roleLabel = 'akun Ibu';
        } else if (ortu.tipe?.toLowerCase() == 'wali') {
          roleLabel = 'akun Wali';
        }

        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red[600]),
              const SizedBox(width: 10),
              Text(
                'Konfirmasi Hapus',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text.rich(
            TextSpan(
              text: 'Apakah anda yakin ingin menghapus $roleLabel ',
              children: [
                TextSpan(
                  text: (ortu.nama?.isNotEmpty ?? false) ? ortu.nama : 'ini',
                  style: TextStyle(
                    fontWeight: (ortu.nama?.isNotEmpty ?? false)
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: (ortu.nama?.isNotEmpty ?? false)
                        ? Colors.black87
                        : null,
                  ),
                ),
                const TextSpan(text: '? Tindakan ini tidak dapat dibatalkan.'),
              ],
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoadingDeleteAccount.value
                    ? null
                    : () {
                        controller.deleteOrtuAccount(ortu.id!.toString());
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: controller.isLoadingDeleteAccount.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Hapus Akun',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
