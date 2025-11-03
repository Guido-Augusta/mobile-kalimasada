import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/santri.dart';
import 'package:mobile_kalimasada/app/modules/santri/santri_home/controllers/santri_home_controller.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/santri_profile_controller.dart';

class SantriProfileView extends GetView<SantriProfileController> {
  const SantriProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Obx(() {
        final santri = controller.santriDetail.value;
        // Data kosong
        if (santri == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_off,
                    size: 40,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Data santri tidak ditemukan',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.getSantriDetail(controller.santriId!);
            if (Get.isRegistered<SantriHomeController>()) {
              Get.find<SantriHomeController>().getSantri();
            }
          },
          child: CustomScrollView(
            slivers: [
              // Custom App Bar with Gradient Background
              SliverAppBar(
                centerTitle: true,
                title: Text(
                  'Profil Santri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.redAccent,
                    ),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
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
                        );
                      },
                    ),
                  ),
                ],
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
                        colors: [
                          Colors.deepPurpleAccent,
                          Colors.deepPurple[700]!,
                        ],
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
                                // Profile Picture with Border and Shadow
                                Stack(
                                  children: [
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

                                // Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Text(
                                    santri.nama ?? 'Nama tidak tersedia',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Tahap Badge
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
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // Pastikan row hanya mengambil lebar seperlunya
                                    children: [
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
                                      Flexible(
                                        // Gunakan Flexible untuk mencegah overflow teks
                                        child: Text(
                                          getTahapLabel(santri.tahapHafalan),
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
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
                    // Stats Cards
                    _buildStatsCards(santri),

                    const SizedBox(height: 24),

                    // Personal Information
                    _buildPersonalInfoSection(santri),

                    const SizedBox(height: 24),

                    // Parents Information
                    _buildParentsInfoSection(santri),

                    const SizedBox(height: 24),

                    // Wali Kelas Information
                    _buildWaliKelasSection(santri),

                    const SizedBox(height: 50), // Space for bottom buttons
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
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

  // Format the date to display in the text field
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _showEditProfileDialog() {
    // Initialize the date controller with the current date of birth
    controller.tanggalLahirC = TextEditingController(
      text: formatDate(controller.santriDetail.value!.tanggalLahir!),
    );

    // Function to show date picker
    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: controller.santriDetail.value!.tanggalLahir!,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (picked != null &&
          picked != controller.santriDetail.value!.tanggalLahir) {
        // controller.santriDetail.value!.tanggalLahir = picked;
        controller.tanggalLahirC.text = formatDate(picked);
      }
    }

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
                      'Pastikan data yang masukkan Anda benar',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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
                  child: Form(
                    key: controller.formKey,
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
                        TextFormField(
                          style: TextStyle(color: Colors.black),
                          controller: controller.namaC,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nama tidak boleh kosong';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nama Lengkap',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            fillColor: Colors.grey[50],
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Nomor HP',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '(Opsional)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: Colors.black),
                          controller: controller.noHpC,
                          validator: (value) {
                            if (value!.isNotEmpty && !value.isNumericOnly) {
                              return 'Nomor HP harus berupa angka';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Masukkan Nomor HP',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            fillColor: Colors.grey[50],
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                        // Inside the form's Column, add this after the alamat field
                        const SizedBox(height: 16),
                        Text(
                          'Tanggal Lahir',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => selectDate(Get.context!),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: controller.tanggalLahirC,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal lahir tidak boleh kosong';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Pilih Tanggal Lahir',
                                hintStyle: TextStyle(color: Colors.grey[500]),
                                prefixIcon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.deepPurple,
                                  size: 20,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.grey[300]!,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
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
                          initialValue: controller.jenisKelaminC.text,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis kelamin tidak boleh kosong';
                            }
                            return null;
                          },
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
                              borderSide: BorderSide(color: Colors.deepPurple),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
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
                        TextFormField(
                          maxLines: 5,
                          minLines: 3,
                          controller: controller.alamatC,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Alamat tidak boleh kosong';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Masukkan Alamat',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            fillColor: Colors.grey[50],
                            filled: true,
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepPurple),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                          if (controller.formKey.currentState!.validate()) {
                            if (controller.namaC.text ==
                                    controller.santriDetail.value?.nama &&
                                controller.noHpC.text ==
                                    controller.santriDetail.value?.nomorHp &&
                                controller.alamatC.text ==
                                    controller.santriDetail.value?.alamat &&
                                controller.jenisKelaminC.text ==
                                    controller
                                        .santriDetail
                                        .value
                                        ?.jenisKelamin &&
                                controller.tanggalLahirC.text ==
                                    formatDate(
                                      controller
                                          .santriDetail
                                          .value!
                                          .tanggalLahir!,
                                    )) {
                              toastification.show(
                                context: Get.context!,
                                title: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Icon(Icons.error, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text(
                                      'Tidak ada perubahan data',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                icon: Icon(Icons.error, color: Colors.white),
                                showIcon: true,
                                backgroundColor: Color(0xFF6B6B6B),
                                borderSide: BorderSide.none,
                                alignment: Alignment.bottomCenter,
                                autoCloseDuration: const Duration(
                                  milliseconds: 2000,
                                ),
                                closeButton: ToastCloseButton(
                                  showType: CloseButtonShowType.none,
                                ),
                                animationBuilder:
                                    (context, animation, alignment, child) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                type: ToastificationType.error,
                                style: ToastificationStyle.simple,
                              );

                              return;
                            }
                            controller.updateProfileData(
                              controller.namaC.text,
                              controller.noHpC.text,
                              controller.alamatC.text,
                              controller.jenisKelaminC.text,
                              controller.tanggalLahirC.text,
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

  // Helper method to get label based on tahap hafalan
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
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: Colors.deepPurpleAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${santri.totalPoin ?? 0}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Total Poin',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
              children: [
                // Edit Profile Button
                const SizedBox(height: 2),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.namaC.text =
                          controller.santriDetail.value!.nama!;
                      controller.noHpC.text =
                          controller.santriDetail.value!.nomorHp!;
                      controller.alamatC.text =
                          controller.santriDetail.value!.alamat!;
                      controller.jenisKelaminC.text =
                          controller.santriDetail.value!.jenisKelamin!;
                      _showEditProfileDialog();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Edit Profil',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed('/change-password');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B46C1),
                      side: const BorderSide(color: Color(0xFF6B46C1)),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Ubah Password',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ],
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _buildInfoTile(
            icon: Icons.credit_card,
            label: 'No. Induk',
            value: santri.noInduk ?? '-',
          ),

          const SizedBox(height: 12),

          _buildInfoTile(
            icon: Icons.email,
            label: 'Email',
            value: santri.user?.email ?? '-',
          ),

          const SizedBox(height: 12),

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

          const SizedBox(height: 12),

          _buildInfoTile(
            icon: Icons.phone,
            label: 'No. Telepon',
            value: santri.nomorHp!.isEmpty || santri.nomorHp == null
                ? '-'
                : santri.nomorHp!,
          ),

          const SizedBox(height: 12),

          _buildInfoTile(
            icon: santri.jenisKelamin!.toLowerCase() == 'l'
                ? Icons.male
                : santri.jenisKelamin!.toLowerCase() == 'p'
                ? Icons.female
                : Icons.person,
            label: 'Jenis Kelamin',
            value: santri.jenisKelamin!.toLowerCase() == 'l'
                ? 'Laki-laki'
                : santri.jenisKelamin!.toLowerCase() == 'p'
                ? 'Perempuan'
                : '-',
          ),

          const SizedBox(height: 12),

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
          if (santri.orangTua.any(
            (element) =>
                element.tipe?.toLowerCase() == 'ayah' ||
                element.tipe?.toLowerCase() == 'ibu',
          ))
            Text(
              'Informasi Orang Tua',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),

          if (santri.orangTua.any(
            (element) => element.tipe?.toLowerCase() == 'wali',
          ))
            Text(
              'Informasi Wali',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),

          if (santri.orangTua.any(
            (element) =>
                element.tipe?.toLowerCase() == 'wali' &&
                santri.orangTua.any(
                  (element) =>
                      element.tipe?.toLowerCase() == 'ayah' ||
                      element.tipe?.toLowerCase() == 'ibu',
                ),
          ))
            Text(
              'Informasi Orang Tua & Wali',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1F2937),
              ),
            ),

          if (santri.orangTua.any(
            (element) =>
                element.tipe?.toLowerCase() == 'ayah' ||
                element.tipe?.toLowerCase() == 'ibu' ||
                element.tipe?.toLowerCase() == 'wali',
          ))
            const SizedBox(height: 16),

          if (santri.orangTua.any(
            (element) => element.tipe?.toLowerCase() == 'ayah',
          ))
            _buildInfoTile(
              icon: Icons.person,
              label: 'Ayah',
              value: controller.getOrangTuaByTipe(santri.orangTua, 'ayah'),
            ),

          if (santri.orangTua.any(
            (element) =>
                element.tipe?.toLowerCase() == 'ayah' &&
                santri.orangTua.any(
                  (element) =>
                      element.tipe?.toLowerCase() == 'ibu' ||
                      element.tipe?.toLowerCase() == 'wali',
                ),
          ))
            const SizedBox(height: 12),

          if (santri.orangTua.any(
            (element) => element.tipe?.toLowerCase() == 'ibu',
          ))
            _buildInfoTile(
              icon: Icons.person,
              label: 'Ibu',
              value: controller.getOrangTuaByTipe(santri.orangTua, 'ibu'),
            ),

          if (santri.orangTua.any(
            (element) =>
                element.tipe?.toLowerCase() == 'ibu' &&
                element.tipe?.toLowerCase() == 'wali',
          ))
            const SizedBox(height: 12),

          if (santri.orangTua.any(
            (element) => element.tipe?.toLowerCase() == 'wali',
          ))
            _buildInfoTile(
              icon: Icons.person,
              label: 'Wali',
              value: controller.getOrangTuaByTipe(santri.orangTua, 'wali'),
            ),
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
            'Informasi Wali Kelas',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),

          const SizedBox(height: 16),

          // Wali Kelas
          _buildInfoTile(
            icon: Icons.school,
            label: 'Wali Kelas Santri',
            value: santri.waliKelas.isNotEmpty
                ? santri.waliKelas.first.nama!
                : '-',
            telepon: santri.waliKelas.isNotEmpty
                ? santri.waliKelas.first.nomorHp
                : '',
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
