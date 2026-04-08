import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import '../controllers/daftar_santri_controller.dart';

class DaftarSantriView extends GetView<DaftarSantriController> {
  const DaftarSantriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text(
          'Daftar Santri',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
      floatingActionButton: Obx(() {
        if (!controller.isAdmin) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: controller.isFabVisible.value
                ? Offset.zero
                : const Offset(2, 0), // geser ke kanan
            child: FloatingActionButton(
              onPressed: () {
                Get.toNamed('/tambah-santri');
              },
              backgroundColor: Colors.deepPurpleAccent,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      }),
      body: RefreshIndicator(
        onRefresh: () async {
          controller.fetchData();
        },
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

              // Button Filter Tahap Hafalan
              buttonFilterTahapan(),

              const SizedBox(height: 8),
              // Student List
              Obx(() {
                if (controller.isLoading.value &&
                    controller.searchQuery.value.isEmpty) {
                  return _buildLoadingIndicator();
                } else if (controller.santriList.isEmpty) {
                  return _buildEmptyState();
                } else if (controller.searchQuery.value.isNotEmpty &&
                    controller.santriList.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  itemCount:
                      controller.santriList.length +
                      (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.santriList.length) {
                      return _buildLoadMoreIndicator();
                    }
                    final santri = controller.santriList[index];
                    if (controller.isAdmin) {
                      return _buildSantriCardForAdmin(santri);
                    } else {
                      return _buildSantriCard(santri);
                    }
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Padding _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
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
        child: Obx(
          () => TextField(
            controller: controller.searchController,
            onChanged: (value) {
              controller.searchQuery.value = value;
            },
            decoration: InputDecoration(
              hintText: 'Cari santri...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: controller.searchQuery.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                      onPressed: () {
                        controller.searchQuery.value = '';
                        controller.searchController.clear();
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding buttonFilterTahapan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Obx(
            () => Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.changeTahapHafalan('level1');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.tahapHafalan.value == 'level1'
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.tahapHafalan.value == 'level1'
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Level 1',
                      style: TextStyle(
                        color: controller.tahapHafalan.value == 'level1'
                            ? Colors.deepPurple
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.changeTahapHafalan('level2');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.tahapHafalan.value == 'level2'
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.tahapHafalan.value == 'level2'
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Level 2',
                      style: TextStyle(
                        color: controller.tahapHafalan.value == 'level2'
                            ? Colors.deepPurple
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Obx(
            () => Expanded(
              child: GestureDetector(
                onTap: () {
                  controller.changeTahapHafalan('level3');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: controller.tahapHafalan.value == 'level3'
                        ? Colors.deepPurpleAccent.withValues(alpha: 0.2)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.tahapHafalan.value == 'level3'
                          ? Colors.deepPurpleAccent.withValues(alpha: 0.3)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey[200]!,
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Level 3',
                      style: TextStyle(
                        color: controller.tahapHafalan.value == 'level3'
                            ? Colors.deepPurple
                            : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSantriCard(Datum santri) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.grey.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.toNamed('/detail-santri', arguments: santri.id.toString());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Profile and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!, width: 2),
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
                              width: 60,
                              height: 60,
                              placeholder: (context, url) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name and Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          santri.nama ?? 'Nama tidak tersedia',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 6),

                        // Badges Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Level Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTahapColor(
                                  santri.tahapHafalan,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getTahapColor(
                                    santri.tahapHafalan,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getTahapLabel(santri.tahapHafalan),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getTahapColor(santri.tahapHafalan),
                                ),
                              ),
                            ),

                            // Gender Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: santri.jenisKelamin?.toLowerCase() == 'l'
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.pink.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      santri.jenisKelamin?.toLowerCase() == 'l'
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.pink.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    santri.jenisKelamin?.toLowerCase() == 'l'
                                        ? Icons.male
                                        : Icons.female,
                                    size: 14,
                                    color:
                                        santri.jenisKelamin?.toLowerCase() ==
                                            'l'
                                        ? Colors.blue
                                        : Colors.pink,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    santri.jenisKelamin?.toLowerCase() == 'l'
                                        ? 'Laki-laki'
                                        : 'Perempuan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          santri.jenisKelamin?.toLowerCase() ==
                                              'l'
                                          ? Colors.blue
                                          : Colors.pink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Action Buttons Section
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.history),
                      label: Text(
                        'Riwayat',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[50],
                        foregroundColor: Colors.orange,
                        shadowColor: Colors.transparent,
                        side: const BorderSide(color: Colors.orange),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(
                          '/riwayat-hafalan',
                          arguments: {'santriId': santri.id.toString()},
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
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[50],
                        foregroundColor: const Color(0xFF10B981),
                        shadowColor: Colors.transparent,
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.toNamed(
                          '/progres-hafalan',
                          arguments: {'santriId': santri.id.toString()},
                        );
                      },
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

  Widget _buildSantriCardForAdmin(Datum santri) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      shadowColor: Colors.grey.withValues(alpha: 0.1),
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.toNamed('/detail-santri', arguments: santri.id.toString());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section with Profile and Basic Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Picture
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey[300]!, width: 2),
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
                              width: 60,
                              height: 60,
                              placeholder: (context, url) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                              errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey[400],
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 30,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Name, No Induk, and Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    santri.nama ?? 'Nama tidak tersedia',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    santri.noInduk ?? 'No Induk tidak tersedia',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: const Text('Edit'),
                                  onTap: () {
                                    Get.toNamed(
                                      '/edit-santri',
                                      arguments: {
                                        'santriId': santri.id.toString(),
                                      },
                                    );
                                  },
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: const Text('Hapus'),
                                  onTap: () {
                                    _showDeleteAccountDialog(context, santri);
                                  },
                                ),
                              ],
                              onSelected: (value) {},
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              popUpAnimationStyle: const AnimationStyle(
                                curve: Curves.easeInOut,
                                duration: Duration(milliseconds: 150),
                              ),
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Badges Row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Level Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getTahapColor(
                                  santri.tahapHafalan,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getTahapColor(
                                    santri.tahapHafalan,
                                  ).withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getTahapLabel(santri.tahapHafalan),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getTahapColor(santri.tahapHafalan),
                                ),
                              ),
                            ),

                            // Gender Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: santri.jenisKelamin?.toLowerCase() == 'l'
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.pink.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      santri.jenisKelamin?.toLowerCase() == 'l'
                                      ? Colors.blue.withValues(alpha: 0.2)
                                      : Colors.pink.withValues(alpha: 0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    santri.jenisKelamin?.toLowerCase() == 'l'
                                        ? Icons.male
                                        : Icons.female,
                                    size: 14,
                                    color:
                                        santri.jenisKelamin?.toLowerCase() ==
                                            'l'
                                        ? Colors.blue
                                        : Colors.pink,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      santri.jenisKelamin?.toLowerCase() == 'l'
                                          ? 'Laki-laki'
                                          : 'Perempuan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            santri.jenisKelamin
                                                    ?.toLowerCase() ==
                                                'l'
                                            ? Colors.blue
                                            : Colors.pink,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Future<dynamic> _showDeleteAccountDialog(BuildContext context, Datum santri) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Hapus Akun',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'Apakah anda yakin ingin menghapus akun ${santri.user?.email ?? 'ini'}?',
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
            const SizedBox(width: 4),
            Obx(
              () => ElevatedButton(
                onPressed: controller.isLoadingDeleteAccount.value
                    ? null
                    : () {
                        controller.deleteSantriAccount(santri.id!.toString());
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
                child: controller.isLoadingDeleteAccount.value
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

  // Helper method to get color based on tahap hafalan
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
        return 'Juz 30';
      case 'level2':
        return 'Surah Pilihan';
      case 'level3':
        return 'Juz 1-29';
      default:
        return 'Tahap ?';
    }
  }

  String _getLevelLabel(String? tahap) {
    switch (tahap?.toLowerCase()) {
      case 'level1':
        return 'Level 1';
      case 'level2':
        return 'Level 2';
      case 'level3':
        return 'Level 3';
      default:
        return 'Level ?';
    }
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 100),
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
                    controller.santriList.isEmpty
                ? 'Santri tidak ditemukan di ${_getLevelLabel(controller.tahapHafalan.value)}'
                : 'Tarik ke bawah untuk refresh',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
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
