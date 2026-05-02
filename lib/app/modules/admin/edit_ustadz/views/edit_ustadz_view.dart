import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utils/toast_utils.dart';
import '../controllers/edit_ustadz_controller.dart';

class EditUstadzView extends GetView<EditUstadzController> {
  const EditUstadzView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Edit Ustadz/ah',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          if (!controller.isLoading.value &&
              controller.ustadzDetail.value == null) {
            return _buildEmptyState();
          }
  
          return RefreshIndicator(
            onRefresh: () => controller.getUstadzDetail(),
            color: Colors.deepPurpleAccent,
            backgroundColor: Colors.white,
            child: CustomScrollView(
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
                            Text(
                              'Edit Data Ustadz/ah',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Perbarui informasi ustadz atau ustadzah.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
  
                            // Foto Profil
                            _buildSectionContainer(
                              title: 'Foto Profil',
                              icon: Icons.camera_alt_rounded,
                              child: _buildPhotoUploadSection(context),
                            ),
                            const SizedBox(height: 20),
  
                            // Informasi Pribadi
                            Skeletonizer(
                              enabled: controller.isLoading.value,
                              child: _buildSectionContainer(
                                title: 'Informasi Pribadi',
                                icon: Icons.person_rounded,
                                child: _buildPersonalInfoSection(),
                              ),
                            ),
                            const SizedBox(height: 20),
  
                            // Wali Kelas Tahap Information
                            Skeletonizer(
                              enabled: controller.isLoading.value,
                              child: _buildSectionContainer(
                                title: 'Wali Kelas',
                                icon: Icons.school_rounded,
                                child: _buildWaliKelasTahapSectionForm(),
                              ),
                            ),
                            const SizedBox(height: 20),
  
                            // Akses Login
                            Skeletonizer(
                              enabled: controller.isLoading.value,
                              child: _buildLoginAccessSection(),
                            ),
                            const SizedBox(height: 32),
  
                            // Buttons
                            Skeletonizer(
                              enabled: controller.isLoading.value,
                              child: SaveProfileButton(
                                controller: controller,
                                formKey: controller.profileFormKey,
                              ),
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
          );
        }),
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
        Skeletonizer(
          enabled: controller.isLoading.value,
          child: Container(
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
                    tag: 'foto-profil-edit-ustadz',
                    child: CachedNetworkImage(
                      imageUrl: controller.fotoProfil.value,
                      fit: BoxFit.cover,
                      placeholder: (c, u) => _placeholderIcon(),
                      errorWidget: (c, u, e) => _placeholderIcon(),
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'foto-profil-edit-ustadz',
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: controller.fotoProfil.value,
                    fit: BoxFit.cover,
                    placeholder: (c, u) => _placeholderIcon(),
                    errorWidget: (c, u, e) => _placeholderIcon(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeletonizer(
                enabled: controller.isLoading.value,
                child: OutlinedButton.icon(
                  onPressed: controller.isUploadingImage.value
                      ? null
                      : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          _showPhotoBottomSheet();
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
                        : 'Ubah Foto',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Skeletonizer(
                enabled: controller.isLoading.value,
                child: Text(
                  'Format yang didukung: JPG, PNG.',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _placeholderIcon() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.person_rounded, size: 40, color: Colors.grey[400]),
    );
  }

  void _showPhotoBottomSheet() {
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

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
      fillColor: Colors.grey[50],
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.deepPurpleAccent),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nama Lengkap'),
        TextFormField(
          controller: controller.namaC,
          style: GoogleFonts.poppins(color: Colors.black),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Nama tidak boleh kosong' : null,
          decoration: _inputDecor('Masukkan nama ustadz/ah'),
        ),
        const SizedBox(height: 16),
        _label('Nomor Telepon'),
        TextFormField(
          controller: controller.noHpC,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.poppins(color: Colors.black),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) {
            if (v!.isEmpty) return 'Nomor telepon tidak boleh kosong';
            if (!v.isNumericOnly) return 'Nomor telepon harus berupa angka';
            return null;
          },
          decoration: _inputDecor('08xxxxxxxxxx'),
        ),
        const SizedBox(height: 16),
        _label('Jenis Kelamin'),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          initialValue: controller.jenisKelaminC.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _inputDecor(''),
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
          ],
          onChanged: (v) => controller.jenisKelaminC.text = v!,
        ),
        const SizedBox(height: 16),
        _label('Alamat'),
        TextFormField(
          controller: controller.alamatC,
          minLines: 3,
          maxLines: 5,
          style: GoogleFonts.poppins(color: Colors.black),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) =>
              (v == null || v.isEmpty) ? 'Alamat tidak boleh kosong' : null,
          decoration: _inputDecor('Masukkan alamat lengkap'),
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

  Widget _buildLoginAccessSection() {
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
          _label('Email'),
          TextFormField(
            controller: controller.emailC,
            enabled: false,
            style: GoogleFonts.poppins(color: Colors.black54),
            decoration: _inputDecor(
              'Email',
            ).copyWith(fillColor: Colors.grey[100]),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showEditEmailPasswordDialog(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Colors.deepPurpleAccent),
                foregroundColor: Colors.deepPurpleAccent,
              ),
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: Text(
                'Edit Email & Password',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditEmailPasswordDialog() {
    controller.emailC.text = controller.ustadzDetail.value!.user!.email!;
    controller.passwordC.text = '';
    controller.isPasswordVisible.value = false;

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.black87],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Text(
                    'Edit Email & Password',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ubah email atau password Ustadz/ah',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.emailPasswordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Email'),
                      TextFormField(
                        controller: controller.emailC,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(color: Colors.black),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: controller.validateEmail,
                        decoration: _inputDecor('Masukkan email baru'),
                      ),
                      const SizedBox(height: 16),
                      _label('Password Baru (Opsional)'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(
                              () => TextFormField(
                                key: controller.passwordFieldKey,
                                controller: controller.passwordC,
                                obscureText:
                                    !controller.isPasswordVisible.value,
                                style: GoogleFonts.poppins(color: Colors.black),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (v) {
                                  if (v != null &&
                                      v.isNotEmpty &&
                                      v.length < 8) {
                                    return 'Password minimal 8 karakter';
                                  }
                                  return null;
                                },
                                decoration: _inputDecor('Password baru')
                                    .copyWith(
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
                                              !controller
                                                  .isPasswordVisible
                                                  .value;
                                        },
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () {
                              controller.passwordC.text = controller
                                  .generatePassword();
                              controller.passwordFieldKey.currentState
                                  ?.validate();
                              controller.isPasswordVisible.value = true;
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: const BorderSide(
                                color: Colors.deepPurpleAccent,
                              ),
                              foregroundColor: Colors.deepPurpleAccent,
                            ),
                            icon: const Icon(
                              Icons.auto_awesome_rounded,
                              size: 18,
                            ),
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
                      const SizedBox(height: 8),
                      Text(
                        'Tekan tombol "Acak" untuk generate password.',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Footer Buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!controller.isSaveEmailPasswordLoading.value) {
                          Get.back();
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        'Batal',
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
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isSaveEmailPasswordLoading.value
                            ? null
                            : () {
                                if (controller
                                    .emailPasswordFormKey
                                    .currentState!
                                    .validate()) {
                                  controller.updateEmailPasswordUstadz(
                                    controller.emailC.text,
                                    controller.passwordC.text,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isSaveEmailPasswordLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Simpan',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_off_rounded,
              size: 64,
              color: Colors.deepPurpleAccent,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Data Tidak Ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat data ustadz.\nSilakan coba lagi.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => controller.getUstadzDetail(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: Colors.deepPurpleAccent),
              foregroundColor: Colors.deepPurpleAccent,
            ),
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              'Muat Ulang',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({
    super.key,
    required this.controller,
    required this.formKey,
  });

  final EditUstadzController controller;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: !controller.isSaveProfileLoading.value
              ? () {
                  FocusScope.of(context).unfocus();
                  if (formKey.currentState!.validate()) {
                    controller.updateProfileUstadz(
                      controller.namaC.text,
                      controller.noHpC.text,
                      controller.alamatC.text,
                      controller.jenisKelaminC.text,
                      controller.waliKelasTahapC.value,
                    );
                  } else {
                    final now = DateTime.now();
                    if (controller.lastErrorShown == null ||
                        now.difference(controller.lastErrorShown!) >
                            const Duration(seconds: 3)) {
                      controller.lastErrorShown = now;
                      ToastUtils.showErrorToast(
                        'Pastikan data yang diisi valid',
                      );
                    }
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
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
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  'Simpan Perubahan',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
