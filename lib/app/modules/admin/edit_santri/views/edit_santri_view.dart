import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../data/models/daftar_ortu.dart';
import '../controllers/edit_santri_controller.dart';

class EditSantriView extends GetView<EditSantriController> {
  const EditSantriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final santri = controller.santriDetail.value;
      final isLoading = controller.isLoading.value;

      return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          title: Text(
            'Edit Santri',
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
        body: () {
          // Data kosong
          if (!isLoading && santri == null) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => controller.getSantriDetail(),
            color: Colors.deepPurpleAccent,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Main Content
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
                              'Perbarui Data Profil',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ubah data santri yang diperlukan.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Personal Information
                            Skeletonizer(
                              enabled: isLoading,
                              child: _buildSectionContainer(
                                title: 'Informasi Pribadi',
                                icon: Icons.person_rounded,
                                child: _buildEditPersonalInfoSection(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Parents Information
                            Skeletonizer(
                              enabled: isLoading,
                              child: _buildSectionContainer(
                                title: 'Data Orang Tua/Wali',
                                icon: Icons.family_restroom_rounded,
                                child: _buildEditParentsSection(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Tahap Hafalan Information
                            Skeletonizer(
                              enabled: isLoading,
                              child: _buildSectionContainer(
                                title: 'Tahap Hafalan',
                                icon: Icons.menu_book_rounded,
                                child: _buildEditTahapHafalanSection(),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Ubah Password Container
                            Skeletonizer(
                              enabled: isLoading,
                              child: _buildPasswordActionContainer(),
                            ),
                            const SizedBox(height: 32),

                            // Save Button
                            Skeletonizer(
                              enabled: isLoading,
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
        }(),
      );
    });
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () => controller.getSantriDetail(),
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
                'Data santri tidak ditemukan',
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
                  color: Colors.grey[500],
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
    return Skeletonizer(
      enabled: controller.isLoading.value,
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
      ),
    );
  }

  Widget _buildEditPersonalInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nama Lengkap',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          style: GoogleFonts.poppins(fontSize: 14),
          controller: controller.namaC,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
          decoration: _inputDecoration('Masukkan Nama Lengkap'),
        ),
      ],
    );
  }

  Widget _buildEditParentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildOrtuSearchField(
          title: 'Ayah',
          isSearching: controller.isSearching,
          tipe: 'ayah',
        ),
        const SizedBox(height: 20),
        buildOrtuSearchField(
          title: 'Ibu',
          isSearching: controller.isSearching,
          tipe: 'ibu',
        ),
        const SizedBox(height: 20),
        buildOrtuSearchField(
          title: 'Wali',
          isSearching: controller.isSearching,
          tipe: 'wali',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.orange[800],
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Minimal satu orang tua/wali harus diisi.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.orange[900],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditTahapHafalanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          initialValue: controller.tahapHafalanC.text.isNotEmpty
              ? controller.tahapHafalanC.text
              : 'Level1',
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Tahap hafalan tidak boleh kosong';
            }
            return null;
          },
          decoration: _inputDecoration('Pilih Tahap Hafalan'),
          dropdownColor: Colors.white,
          icon: const Icon(Icons.expand_more_rounded, color: Colors.grey),
          items: [
            DropdownMenuItem(value: 'Level1', child: Text('Level 1 - Juz 30')),
            DropdownMenuItem(
              value: 'Level2',
              child: Text('Level 2 - Surah Pilihan'),
            ),
            DropdownMenuItem(
              value: 'Level3',
              child: Text('Level 3 - Juz 1-29'),
            ),
          ],
          onChanged: (value) {
            controller.tahapHafalanC.text = value!;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordActionContainer() {
    return Skeletonizer(
      enabled: controller.isLoading.value,
      child: Container(
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
        child: Row(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Password',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ubah password santri',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _showEditPasswordDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[50],
                foregroundColor: Colors.deepPurpleAccent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text(
                'Ubah',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPasswordDialog() {
    controller.passwordC.text = '';
    controller.isPasswordVisible.value = false;

    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ubah Password',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: controller.passwordFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Password Baru',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => TextFormField(
                          controller: controller.passwordC,
                          obscureText: !controller.isPasswordVisible.value,
                          style: GoogleFonts.poppins(color: Colors.black),
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password baru tidak boleh kosong';
                            }
                            if (value.length < 8) {
                              return 'Password minimal 8 karakter';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Ketik password baru...',
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            fillColor: Colors.grey[50],
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordVisible.value
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                controller.isPasswordVisible.toggle();
                              },
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
                              borderSide: const BorderSide(
                                color: Colors.deepPurple,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),

                      // Generate Button
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            controller.passwordC.text = controller
                                .generatePassword();
                            controller.isPasswordVisible.value = true;
                            controller.passwordFormKey.currentState?.validate();
                          },
                          icon: const Icon(Icons.autorenew_rounded, size: 18),
                          label: Text(
                            'Buat Otomatis',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Action Buttons
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSavePasswordLoading.value
                              ? null
                              : () {
                                  if (controller.passwordFormKey.currentState!
                                      .validate()) {
                                    controller.updatePasswordSantri(
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
                          child: controller.isSavePasswordLoading.value
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
                                  'Simpan Password',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrtuSearchField({
    required String title,
    required RxBool isSearching,
    required String tipe,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),

        DropdownSearch<Datum>(
          compareFn: (item1, item2) => item1.id == item2.id,
          items: (f, cs) => controller.loadOrtuByTipe(tipe, f),
          itemAsString: (Datum u) => u.nama ?? '',
          selectedItem: controller.getSelectedOrtuByTipe(tipe),
          onChanged: (Datum? selectedItem) {
            if (tipe == 'ayah') {
              controller.selectedAyah.value = selectedItem;
            } else if (tipe == 'ibu') {
              controller.selectedIbu.value = selectedItem;
            } else if (tipe == 'wali') {
              controller.selectedWali.value = selectedItem;
            }
          },
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: 'Pilih $title...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
                size: 20,
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
                borderSide: const BorderSide(color: Colors.deepPurple),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: PopupProps.modalBottomSheet(
            modalBottomSheetProps: const ModalBottomSheetProps(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
            showSearchBox: true,
            searchDelay: const Duration(milliseconds: 500),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari $title...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurple),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            emptyBuilder: (context, searchEntry) => Center(
              child: Obx(
                () => !controller.isSearching.value
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Data $title tidak ditemukan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba dengan kata kunci yang berbeda',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            loadingBuilder: (context, searchEntry) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.deepPurple,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Mencari $title...',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  height: 5,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            itemBuilder: (context, item, isDisabled, isSelected) {
              return Obx(
                () => !controller.isSearching.value
                    ? ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent.withValues(
                              alpha: 0.1,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person,
                            color: Colors.deepPurpleAccent,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          item.nama ?? '',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
          validator: (value) {
            if (!controller.isLoading.value &&
                (controller.selectedAyah.value == null &&
                    controller.selectedIbu.value == null &&
                    controller.selectedWali.value == null)) {
              return 'Minimal satu orang tua harus dipilih';
            }
            return null;
          },
          autoValidateMode: AutovalidateMode.always,
          suffixProps: const DropdownSuffixProps(
            clearButtonProps: ClearButtonProps(
              isVisible: true,
              icon: Icon(Icons.close_rounded, size: 20),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14),
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
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({
    super.key,
    required this.controller,
    required this.formKey,
  });

  final EditSantriController controller;
  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Skeletonizer(
        enabled: controller.isLoading.value,
        child: ElevatedButton(
          onPressed: !controller.isSaveProfileLoading.value
              ? () {
                  if (formKey.currentState!.validate()) {
                    controller.updateProfileSantri(
                      controller.namaC.text,
                      controller.tahapHafalanC.text,
                      controller.selectedAyah.value,
                      controller.selectedIbu.value,
                      controller.selectedWali.value,
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
      ),
    );
  }
}
