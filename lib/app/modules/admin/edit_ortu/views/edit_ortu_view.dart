import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../utils/toast_utils.dart';
import '../controllers/edit_ortu_controller.dart';

class EditOrtuView extends GetView<EditOrtuController> {
  const EditOrtuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Edit Orang Tua',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (!controller.isLoading.value &&
            controller.ortuDetail.value == null) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () => controller.getOrtuDetail(),
          color: Colors.deepPurpleAccent,
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
                            'Edit Data Orang Tua',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Perbarui informasi orang tua/wali santri.',
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
                    tag: 'foto-profil-edit',
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
                tag: 'foto-profil-edit',
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
              Text(
                'Format: JPG, PNG. (Opsional)',
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

  Widget _placeholderIcon() {
    return Container(
      color: Colors.grey[100],
      child: Icon(Icons.person_rounded, size: 40, color: Colors.grey[400]),
    );
  }

  void _showPhotoBottomSheet() {
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
              onTap: () async {
                Get.back();
                await controller.pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              minTileHeight: 40,
              leading: Icon(Icons.photo_outlined),
              title: Text('Galeri'),
              onTap: () async {
                Get.back();
                await controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
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
          decoration: _inputDecor('Masukkan nama orang tua/wali'),
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
        _label('Tipe Orang Tua'),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          initialValue: controller.tipeC.text,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _inputDecor(''),
          items: const [
            DropdownMenuItem(value: 'Ayah', child: Text('Ayah')),
            DropdownMenuItem(value: 'Ibu', child: Text('Ibu')),
            DropdownMenuItem(value: 'Wali', child: Text('Wali')),
          ],
          onChanged: (v) => controller.tipeC.text = v!,
        ),
        const SizedBox(height: 16),
        _label('Alamat'),
        TextFormField(
          controller: controller.alamatC,
          focusNode: controller.alamatFocusNode,
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
                    'Kredensial untuk orang tua/wali',
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
    controller.emailC.text = controller.ortuDetail.value!.user!.email!;
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
                    'Ubah email atau password Orang Tua',
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
                        validator: controller.validateEmail,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        keyboardType: TextInputType.emailAddress,
                        style: GoogleFonts.poppins(color: Colors.black),
                        decoration: _inputDecor('Masukkan email'),
                      ),
                      const SizedBox(height: 16),
                      _label('Password'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Obx(
                              () => TextFormField(
                                controller: controller.passwordC,
                                obscureText:
                                    !controller.isPasswordVisible.value,
                                style: GoogleFonts.poppins(color: Colors.black),
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
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password tidak boleh kosong';
                                  }
                                  if (v.length < 8) {
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
                              controller.passwordC.text = controller
                                  .generatePassword();
                              controller.isPasswordVisible.value = true;
                              controller.emailPasswordFormKey.currentState
                                  ?.validate();
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
                            icon: const Icon(Icons.autorenew_rounded, size: 18),
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
                ),
              ),
            ),
            // Actions
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey[400]!),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
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
                                  controller.updateEmailPasswordOrtu(
                                    controller.emailC.text,
                                    controller.passwordC.text,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isSaveEmailPasswordLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                'Simpan',
                                style: GoogleFonts.poppins(
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
    return RefreshIndicator(
      onRefresh: () => controller.getOrtuDetail(),
      color: Colors.deepPurpleAccent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 500,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person_off_outlined,
                  size: 48,
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Data orang tua tidak ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tarik ke bawah untuk memuat ulang',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
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

  final EditOrtuController controller;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: !controller.isSaveProfileLoading.value
            ? () {
                controller.alamatFocusNode.unfocus();
                FocusScope.of(Get.context!).unfocus();
                if (formKey.currentState!.validate()) {
                  controller.updateProfileOrtu(
                    controller.namaC.text,
                    controller.noHpC.text,
                    controller.alamatC.text,
                    controller.jenisKelaminC.text,
                    controller.tipeC.text,
                  );
                } else {
                  final now = DateTime.now();
                  if (controller.lastErrorShown == null ||
                      now.difference(controller.lastErrorShown!) >
                          Duration(seconds: 3)) {
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
                'Simpan Perubahan',
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
