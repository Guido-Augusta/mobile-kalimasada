import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../utils/toast_utils.dart';
import '../controllers/tambah_ustadz_controller.dart';

class TambahUstadzView extends GetView<TambahUstadzController> {
  const TambahUstadzView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Tambah Ustadz/ah Baru',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<TambahUstadzController>(
          builder: (_) => CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Form(
                      key: controller.profileFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Title
                          Text(
                            'Daftarkan Ustadz/ah Baru',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Silakan lengkapi data ustadz atau ustadzah.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),
  
                          // Foto Profil Section
                          _buildSectionContainer(
                            title: 'Foto Profil',
                            icon: Icons.camera_alt_rounded,
                            child: _buildPhotoUploadSection(context),
                          ),
                          const SizedBox(height: 20),
  
                          // Personal Information
                          _buildSectionContainer(
                            title: 'Informasi Pribadi',
                            icon: Icons.person_rounded,
                            child: _buildPersonalInfoSectionForm(),
                          ),
                          const SizedBox(height: 20),
  
                          // Wali Kelas Tahap Information
                          _buildSectionContainer(
                            title: 'Wali Kelas',
                            icon: Icons.school_rounded,
                            child: _buildWaliKelasTahapSectionForm(),
                          ),
                          const SizedBox(height: 20),
  
                          // Akses Login
                          _buildLoginAccessSectionForm(),
                          const SizedBox(height: 32),
  
                          // Save Button
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: OutlinedButton(
                                  onPressed: () {
                                    controller.resetForm();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: BorderSide(color: Colors.grey[400]!),
                                  ),
                                  child: Text(
                                    'Reset',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: SaveProfileButton(controller: controller),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.deepPurpleAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPhotoUploadSection(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!, width: 2),
              ),
              child: GestureDetector(
                onTap: () {
                  FullscreenImageViewer.open(
                    context: context,
                    child: Hero(
                      tag: 'foto-profil-tambah-ustadz',
                      child: Obx(
                        () => controller.pickedImage.value != null
                            ? Image.file(
                                File(controller.pickedImage.value!.path),
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: controller.getImageUrl(
                                  controller.defaultPhotoProfile.value,
                                ),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[100],
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 40,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  );
                },
                child: Hero(
                  tag: 'foto-profil-tambah-ustadz',
                  child: ClipOval(
                    child: Obx(
                      () => controller.pickedImage.value != null
                          ? Image.file(
                              File(controller.pickedImage.value!.path),
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: controller.getImageUrl(
                                controller.defaultPhotoProfile.value,
                              ),
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[100],
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[100],
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => controller.pickedImage.value != null
                  ? Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          controller.deleteImage();
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(
                () => OutlinedButton.icon(
                  onPressed: controller.isUploadingImage.value
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _showEditPhotoProfileBottomSheet();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: const BorderSide(color: Colors.deepPurpleAccent),
                    foregroundColor: Colors.deepPurpleAccent,
                  ),
                  icon: controller.isUploadingImage.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.deepPurpleAccent,
                          ),
                        )
                      : const Icon(Icons.upload_rounded, size: 18),
                  label: Text(
                    controller.isUploadingImage.value
                        ? 'Mengunggah...'
                        : 'Pilih Foto',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Format yang didukung: JPG, PNG. (Opsional)',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditPhotoProfileBottomSheet() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
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
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Kamera'),
                onTap: () async {
                  Get.back();
                  await controller.pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                minTileHeight: 40,
                leading: const Icon(Icons.photo_outlined),
                title: const Text('Galeri'),
                onTap: () async {
                  Get.back();
                  await controller.pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int? minLines,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines ?? 1,
          style: GoogleFonts.poppins(color: Colors.black),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            fillColor: Colors.grey[50],
            filled: true,
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
              borderSide: const BorderSide(color: Colors.deepPurpleAccent),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSectionForm() {
    return Column(
      children: [
        _buildTextField(
          label: 'Nama Lengkap',
          hintText: 'Masukkan nama lengkap',
          controller: controller.namaC,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Nomor Telepon',
          hintText: '08xxxxxxxxxx',
          controller: controller.noHpC,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value!.isEmpty) {
              return 'Nomor telepon tidak boleh kosong';
            }
            if (value.isNotEmpty && !value.isNumericOnly) {
              return 'Nomor telepon harus berupa angka';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jenis Kelamin',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: controller.jenisKelaminC.text,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Jenis kelamin tidak boleh kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                fillColor: Colors.grey[50],
                filled: true,
                hintText: 'Pilih jenis kelamin',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
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
                  borderSide: const BorderSide(color: Colors.deepPurpleAccent),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              dropdownColor: Colors.white,
              items: const [
                DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                DropdownMenuItem(value: 'P', child: Text('Perempuan')),
              ],
              onChanged: (value) {
                controller.jenisKelaminC.text = value!;
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Alamat',
          hintText: 'Masukkan alamat lengkap',
          controller: controller.alamatC,
          minLines: 3,
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Alamat tidak boleh kosong';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWaliKelasTahapSectionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Penanggung Jawab Kelas',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(Opsional)',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => InputDecorator(
            decoration: InputDecoration(
              fillColor: Colors.grey[50],
              filled: true,
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
                borderSide: const BorderSide(color: Colors.deepPurpleAccent),
              ),
              contentPadding: const EdgeInsets.fromLTRB(16, 2, 8, 2),
              suffixIcon: controller.waliKelasTahapC.value.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear_rounded,
                        size: 20,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        controller.waliKelasTahapC.value = '';
                      },
                    )
                  : null,
            ),
            child: DropdownButton<String>(
              value: controller.waliKelasTahapC.value.isEmpty
                  ? null
                  : controller.waliKelasTahapC.value,
              isExpanded: true,
              dropdownColor: Colors.white,
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
              hint: Text(
                'Pilih Tingkatan Ajar',
                style: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Level1',
                  child: Text('Level 1 (Juz 30)'),
                ),
                DropdownMenuItem(
                  value: 'Level2',
                  child: Text('Level 2 (Surah Pilihan)'),
                ),
                DropdownMenuItem(
                  value: 'Level3',
                  child: Text('Level 3 (Juz 1-29)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  controller.waliKelasTahapC.value = value;
                }
              },
              underline: const SizedBox(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginAccessSectionForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.vpn_key_rounded,
                  color: Colors.deepPurpleAccent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Akses Login',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Kredensial untuk ustadz/ah',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Email',
            hintText: 'Masukkan email aktif',
            controller: controller.emailC,
            keyboardType: TextInputType.emailAddress,
            validator: controller.validateEmail,
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Password',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Obx(
                      () => TextFormField(
                        key: controller.passwordFieldKey,
                        controller: controller.passwordC,
                        obscureText: !controller.isPasswordVisible.value,
                        style: GoogleFonts.poppins(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          fillColor: Colors.grey[50],
                          filled: true,
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
                            borderSide: const BorderSide(
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            onPressed: () {
                              controller.isPasswordVisible.value =
                                  !controller.isPasswordVisible.value;
                            },
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      controller.passwordC.text = controller.generatePassword();
                      controller.passwordFieldKey.currentState?.validate();
                      controller.isPasswordVisible.value = true;
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.deepPurpleAccent),
                      foregroundColor: Colors.deepPurpleAccent,
                    ),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                    label: Text(
                      'Acak',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Tekan tombol "Acak" untuk generate password.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({super.key, required this.controller});

  final TambahUstadzController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: !controller.isSaveProfileLoading.value
            ? () {
                FocusScope.of(Get.context!).unfocus();
                if (controller.profileFormKey.currentState!.validate()) {
                  controller.addUstadz(
                    controller.pickedImage.value,
                    controller.emailC.text,
                    controller.passwordC.text,
                    controller.namaC.text,
                    controller.noHpC.text,
                    controller.jenisKelaminC.text,
                    controller.alamatC.text,
                    controller.waliKelasTahapC.value,
                  );
                } else {
                  final now = DateTime.now();
                  if (controller.lastErrorShown == null ||
                      now.difference(controller.lastErrorShown!) >
                          const Duration(seconds: 3)) {
                    controller.lastErrorShown = now;
                    ToastUtils.showErrorToast('Pastikan data yang diisi valid');
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: controller.isSaveProfileLoading.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Menyimpan...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Text(
                'Simpan Data',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
