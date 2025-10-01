import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/ustadz_profile_controller.dart';

class UstadzProfileView extends GetView<UstadzProfileController> {
  const UstadzProfileView({super.key});

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
                  colors: [Colors.deepPurple[700]!, Colors.deepPurpleAccent],
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
                    Stack(
                      children: [
                        Material(
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () {
                              _showEditPhotoProfileBottomSheet();
                            },
                            customBorder: const CircleBorder(),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Obx(
                                () => CircleAvatar(
                                  radius: 50,
                                  backgroundImage: CachedNetworkImageProvider(
                                    controller.getImageUrl(
                                      controller.fotoProfil.value,
                                    ),
                                  ),
                                  onBackgroundImageError: (exception, stackTrace) {
                                    // Handle image loading error
                                    controller.fotoProfil.value =
                                        'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg';
                                  },
                                  child: Obx(
                                    () =>
                                        controller.fotoProfil.value.isEmpty ||
                                            controller.fotoProfil.value == ''
                                        ? Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.deepPurple,
                                          )
                                        : SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Material(
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () {
                                _showEditPhotoProfileBottomSheet();
                              },
                              customBorder: const CircleBorder(),
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
                          ),
                        ),
                      ],
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
                      () => controller.ustadzData.value?.waliKelasTahap != null
                          ? Row(
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
                                        _getTahapLabel(
                                          controller
                                                  .ustadzData
                                                  .value
                                                  ?.waliKelasTahap ??
                                              '',
                                        ),
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
                            )
                          : const SizedBox.shrink(),
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
                        controller.ustadzData.value?.waliKelasTahap != null
                            ? _buildInfoCard(
                                Icons.star_border_purple500_rounded,
                                'Wali Kelas Tahap',
                                _getTahapLabel(
                                  controller.ustadzData.value?.waliKelasTahap ??
                                      '',
                                ),
                                1,
                              )
                            : const SizedBox.shrink(),
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
                            controller.namaC.text =
                                controller.ustadzData.value!.nama!;
                            controller.noHpC.text =
                                controller.ustadzData.value!.nomorHp!;
                            controller.alamatC.text =
                                controller.ustadzData.value!.alamat!;
                            controller.jenisKelaminC.text =
                                controller.ustadzData.value!.jenisKelamin!;
                            _showEditProfileDialog();
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
                            Get.dialog(
                              AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Logout',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                  ),
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
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      controller.logout();
                                    },
                                    style: TextButton.styleFrom(
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
                                    child: Text(
                                      'Ya',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
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

  void _showEditProfileDialog() {
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
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
                    const SizedBox(height: 8),
                    Text(
                      'Pastikan data yang Anda benar',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          style: TextStyle(color: Colors.black),
                          controller: controller.namaC,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nama Lengkap',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nomor HP',
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
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: Colors.black),
                          controller: controller.noHpC,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nomor HP',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Jenis Kelamin',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: controller.jenisKelaminC.text,
                        decoration: InputDecoration(
                          fillColor: Colors.grey[50],
                          filled: true,
                          hintText: 'Pilih Jenis Kelamin',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                        ),
                        dropdownColor: Colors.white,
                        items: const [
                          DropdownMenuItem(
                            value: 'P',
                            child: Text('Perempuan'),
                          ),
                          DropdownMenuItem(
                            value: 'L',
                            child: Text('Laki-laki'),
                          ),
                        ],
                        onChanged: (value) {
                          controller.jenisKelaminC.text = value!;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Alamat',
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
                          maxLines: 5,
                          minLines: 3,
                          controller: controller.alamatC,
                          decoration: InputDecoration(
                            hintText: 'Masukkan Alamat',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  color: Colors.grey[50],
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
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.namaC.text.isEmpty ||
                              controller.noHpC.text.isEmpty ||
                              controller.alamatC.text.isEmpty ||
                              controller.jenisKelaminC.text.isEmpty) {
                            Get.snackbar('Error', 'Semua field harus diisi');
                            return;
                          }
                          if (controller.namaC.text ==
                                  controller.ustadzData.value?.nama &&
                              controller.noHpC.text ==
                                  controller.ustadzData.value?.nomorHp &&
                              controller.alamatC.text ==
                                  controller.ustadzData.value?.alamat &&
                              controller.jenisKelaminC.text ==
                                  controller.ustadzData.value?.jenisKelamin) {
                            Get.snackbar('Error', 'Tidak ada perubahan data');
                            return;
                          }
                          controller.updateProfileData(
                            controller.namaC.text,
                            controller.noHpC.text,
                            controller.alamatC.text,
                            controller.jenisKelaminC.text,
                          );
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
                        child: Obx(
                          () => controller.isSaveLoading.value
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

  void _showEditPhotoProfileBottomSheet() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Foto Profil',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            ListTile(
              minTileHeight: 40,
              leading: Icon(Icons.camera_alt_outlined),
              title: Text('Kamera'),
              onTap: () {
                controller.pickImage(ImageSource.camera);
                Get.back();
              },
            ),
            ListTile(
              minTileHeight: 40,
              leading: Icon(Icons.photo_outlined),
              title: Text('Galeri'),
              onTap: () {
                controller.pickImage(ImageSource.gallery);
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

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
            color: Colors.grey.withValues(alpha: 0.1),
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

  String _getTahapLabel(String tahap) {
    switch (tahap) {
      case 'Level1':
        return 'Level 1';
      case 'Level2':
        return 'Level 2';
      case 'Level3':
        return 'Level 3';
      default:
        return 'Tahap tidak ditemukan';
    }
  }
}
