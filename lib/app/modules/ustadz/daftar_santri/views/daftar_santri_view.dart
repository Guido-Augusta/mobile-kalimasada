import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:mobile_kalimasada/app/data/models/surah.dart';
import 'package:searchfield/searchfield.dart';
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
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
              child: InkWell(
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
              child: InkWell(
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
              child: InkWell(
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
                          santri.fotoProfil != null ||
                              santri.fotoProfil!.isNotEmpty ||
                              santri.fotoProfil! != ''
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

                            // Points Badge
                            if (santri.totalPoin != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${santri.totalPoin} Poin',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber,
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

              const SizedBox(height: 16),

              // Action Buttons Section
              Row(
                children: [
                  // Murajaah Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.getProgresHafalan(santri.id.toString());
                        _showMurajaahDialog(santri);
                      },
                      icon: const Icon(
                        Icons.menu_book_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Murajaah',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent.withValues(
                          alpha: 0.8,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.orangeAccent.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Hafalan Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        controller.getProgresHafalan(santri.id.toString());
                        _showHafalanDialog(santri);
                      },
                      icon: const Icon(
                        Icons.book,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Hafalan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: Colors.green.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
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
                          santri.fotoProfil != null ||
                              santri.fotoProfil!.isNotEmpty ||
                              santri.fotoProfil! != ''
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
                            Column(
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
                                const SizedBox(height: 4),
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

                        const SizedBox(height: 12),

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
                                _getTahapLabel2(santri.tahapHafalan),
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
        return 'Level 1';
      case 'level2':
        return 'Level 2';
      case 'level3':
        return 'Level 3';
      default:
        return 'Tahap ?';
    }
  }

  String _getTahapLabel2(String? tahap) {
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

  // Method to show hafalan dialog
  void _showHafalanDialog(Datum santri) {
    controller.statusSetoran.value = 'TambahHafalan';
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeaderDialog(santri, 'Tambah Hafalan'),

              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingProgresHafalan.value) {
                    return _buildLoadingStateDialog();
                  }

                  // Cek jika ada error atau data kosong
                  if (controller.progresHafalan.isEmpty) {
                    return _buildErrorStateDialog(santri);
                  }

                  return _buildFormHafalanDialog();
                }),
              ),

              // Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                          Future.delayed(const Duration(milliseconds: 500), () {
                            controller.selectedSurahHafalan.value = null;
                            controller.currentAyat.value = 0;
                            controller.totalAyat.value = 0;
                            controller.progressPercentage.value = 0;
                            controller.progresHafalan.value = [];
                            controller.inputJumlahAyatController.text = '';
                            controller.ayatList.clear();
                            controller.statusSetoran.value = '';
                            controller.catatanController.clear();
                          });
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
                          onPressed:
                              (controller.isSaveLoading.value ||
                                  controller.isLoadingProgresHafalan.value ||
                                  controller.progresHafalan.isEmpty)
                              ? null
                              : () {
                                  if (controller.formKeyHafalan.currentState!
                                      .validate()) {
                                    controller.saveHafalan(
                                      santri.id.toString(),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: controller.isSaveLoading.value
                                ? EdgeInsets.symmetric(vertical: 4)
                                : EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSaveLoading.value
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
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

  Container _buildHeaderDialog(Datum santri, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            santri.nama ?? '-',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Tanggal Hari ini
          Text(
            '${_getHariIni()}, ${_formatTanggal(DateTime.now())}',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
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
                    color: _getTahapColor(santri.tahapHafalan),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _getTahapLabel2(santri.tahapHafalan),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SingleChildScrollView _buildFormHafalanDialog() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: controller.formKeyHafalan,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Surah Search
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Surah',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SearchField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap pilih surah';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  suggestions: controller.surahList.map((Surah surah) {
                    return SearchFieldListItem<Surah>(
                      surah.namaLatin!,
                      value: surah.namaLatin,
                      item: surah,
                      key: ValueKey(surah.id),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${surah.nomor}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            surah.namaLatin!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${surah.totalAyat!} Ayat',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  selectedValue: controller.selectedSurahHafalan.value,
                  onSuggestionTap: (SearchFieldListItem x) {
                    controller.selectedSurahHafalan.value =
                        x as SearchFieldListItem<Surah>;
                    controller.onSurahSelected(x.item);
                  },
                  suggestionState: Suggestion.expand,
                  textInputAction: TextInputAction.next,
                  suggestionsDecoration: SuggestionDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  searchInputDecoration: SearchInputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: 'Cari surah...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.deepPurpleAccent,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.selectedSurahHafalan.value != null) {
                        return IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            controller.selectedSurahHafalan.value = null;
                            controller.currentAyat.value = 0;
                            controller.totalAyat.value = 0;
                            controller.progressPercentage.value = 0;
                            controller.detailHafalan.value = null;
                            controller.inputJumlahAyatController.clear();
                            controller.ayatList.clear();
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    fillColor: Colors.grey[50],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Progress Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Progres Ayat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.currentAyat.value} / ${controller.totalAyat.value}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Obx(
                    () => LinearProgressIndicator(
                      value: controller.progressPercentage.value,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Jumlah Ayat
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jumlah Ayat',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan jumlah ayat';
                    }
                    if (int.parse(value) <= 0) {
                      return 'Jumlah ayat harus lebih dari 0';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Masukkan jumlah ayat',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    fillColor: Colors.grey[50],
                    filled: true,
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    prefixIcon: const Icon(
                      Icons.format_list_numbered,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                  controller: controller.inputJumlahAyatController,
                  onChanged: (value) {
                    controller.inputJumlahAyatController.text = value;
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Catatan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: controller.catatanController,
                    maxLines: 5,
                    minLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Keterangan hafalan (opsional)',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      border: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.deepPurpleAccent),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(
                          Icons.note_alt_outlined,
                          color: Colors.deepPurpleAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Center _buildErrorStateDialog(Datum santri) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Gagal memuat data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Periksa koneksi internet Anda',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              controller.getProgresHafalan(santri.id.toString());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Coba Lagi',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Center _buildLoadingStateDialog() {
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

  // Method to show hafalan dialog
  void _showMurajaahDialog(Datum santri) {
    controller.statusSetoran.value = 'Murajaah';
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              _buildHeaderDialog(santri, 'Murajaah'),

              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingProgresHafalan.value) {
                    return _buildLoadingStateDialog();
                  }

                  // Cek jika ada error atau data kosong
                  if (controller.progresHafalan.isEmpty) {
                    return _buildErrorStateDialog(santri);
                  }

                  return _buildFormMurajaahDialog();
                }),
              ),

              // Actions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                          Future.delayed(const Duration(milliseconds: 500), () {
                            controller.selectedSurahMurajaah.value = null;
                            controller.ayatList.clear();
                            controller.currentAyat.value = 0;
                            controller.totalAyat.value = 0;
                            controller.progressPercentage.value = 0;
                            controller.progresHafalan.value = [];
                            controller.statusSetoran.value = '';
                            controller.catatanController.clear();
                            controller.inputAyatMulaiC.clear();
                            controller.inputAyatAkhirC.clear();
                          });
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
                          onPressed:
                              (controller.isSaveLoading.value ||
                                  controller.isLoadingProgresHafalan.value ||
                                  controller.progresHafalan.isEmpty)
                              ? null
                              : () {
                                  if (controller.formKeyMurajaah.currentState!
                                      .validate()) {
                                    controller.saveMurajaah(
                                      santri.id.toString(),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurpleAccent,
                            padding: controller.isSaveLoading.value
                                ? EdgeInsets.symmetric(vertical: 4)
                                : EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSaveLoading.value
                              ? Transform.scale(
                                  scale: 0.5,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
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

  SingleChildScrollView _buildFormMurajaahDialog() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Form(
        key: controller.formKeyMurajaah,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Surah Search
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Surah',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                SearchField(
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap pilih surah';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  suggestions: controller.surahList.map((Surah surah) {
                    return SearchFieldListItem<Surah>(
                      surah.namaLatin!,
                      value: surah.namaLatin,
                      item: surah,
                      key: ValueKey(surah.id),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${surah.nomor}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            surah.namaLatin!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${surah.totalAyat!} Ayat',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  selectedValue: controller.selectedSurahMurajaah.value,
                  onSuggestionTap: (SearchFieldListItem x) {
                    controller.selectedSurahMurajaah.value =
                        x as SearchFieldListItem<Surah>;
                    controller.onSurahSelected(x.item);
                  },
                  suggestionState: Suggestion.expand,
                  textInputAction: TextInputAction.next,
                  suggestionsDecoration: SuggestionDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  searchInputDecoration: SearchInputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: 'Cari surah...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.deepPurpleAccent,
                    ),
                    suffixIcon: Obx(() {
                      if (controller.selectedSurahMurajaah.value != null) {
                        return IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            controller.selectedSurahMurajaah.value = null;
                            controller.ayatList.clear();
                            controller.currentAyat.value = 0;
                            controller.totalAyat.value = 0;
                            controller.progressPercentage.value = 0;
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    fillColor: Colors.grey[50],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Progress Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Progres Ayat',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Obx(
                      () => Text(
                        '${controller.currentAyat.value} / ${controller.totalAyat.value}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Progress Bar
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Obx(
                    () => LinearProgressIndicator(
                      value: controller.progressPercentage.value,
                      backgroundColor: Colors.grey[200],
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Ayat Dropdown
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayat Mulai',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan ayat';
                          }
                          if (int.parse(value) <= 0) {
                            return 'Harus lebih dari 0';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          prefixIcon: const Icon(
                            Icons.format_list_numbered,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        controller: controller.inputAyatMulaiC,
                        onChanged: (value) {
                          controller.inputAyatMulaiC.text = value;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayat Selesai',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Masukkan ayat';
                          }
                          final ayatMulai =
                              int.tryParse(controller.inputAyatMulaiC.text) ??
                              0;
                          final ayatAkhir = int.tryParse(value) ?? 0;
                          if (ayatAkhir <= 0) {
                            return 'Harus lebih dari 0';
                          }
                          if (ayatAkhir < ayatMulai) {
                            return 'Harus lebih besar dari ayat mulai';
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          prefixIcon: const Icon(
                            Icons.format_list_numbered,
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                        controller: controller.inputAyatAkhirC,
                        onChanged: (value) {
                          controller.inputAyatAkhirC.text = value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Catatan
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller.catatanController,
                  maxLines: 5,
                  minLines: 3,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[50],
                    hintText: 'Keterangan hafalan (opsional)',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.deepPurpleAccent),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Icon(
                        Icons.note_alt_outlined,
                        color: Colors.deepPurpleAccent,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
                ? 'Santri tidak ditemukan di ${_getTahapLabel(controller.tahapHafalan.value)}'
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

  // Method untuk mendapatkan nama hari dalam bahasa Indonesia
  String _getHariIni() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return '';
    }
  }

  // Method untuk memformat tanggal dalam format Indonesia (contoh: 10 Oktober 2023)
  String _formatTanggal(DateTime date) {
    final months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
