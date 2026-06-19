import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/daftar_ortu.dart';
import '../../../../utils/toast_utils.dart';
import '../controllers/tambah_santri_controller.dart';

class TambahSantriView extends GetView<TambahSantriController> {
  const TambahSantriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          'Tambah Santri Baru',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
      ),
      body: SafeArea(
        top: false,
        child: GetBuilder<TambahSantriController>(
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
                            'Daftarkan Santri Baru',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Silakan lengkapi data santri baru.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Nama Lengkap
                          _buildSectionContainer(
                            title: 'Informasi Pribadi',
                            icon: Icons.person_rounded,
                            child: _buildPersonalInfoSectionForm(),
                          ),
                          const SizedBox(height: 20),

                          // Orang Tua/Wali
                          Form(
                            key: controller.ortuFormKey,
                            child: _buildSectionContainer(
                              title: 'Orang Tua/Wali',
                              icon: Icons.family_restroom_rounded,
                              child: _buildParentsSectionForm(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tahap Hafalan
                          _buildSectionContainer(
                            title: 'Tahap Hafalan',
                            icon: Icons.menu_book_rounded,
                            child: _buildTahapHafalanSectionForm(),
                          ),
                          const SizedBox(height: 20),

                          // Password
                          _buildPasswordActionContainer(),
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
                                child: SaveProfileButton(
                                  controller: controller,
                                ),
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

  Widget _buildPersonalInfoSectionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          controller: controller.namaC,
          style: GoogleFonts.poppins(color: Colors.black),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Nama tidak boleh kosong';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Masukkan nama santri',
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey[400],
              fontSize: 14,
            ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParentsSectionForm() {
    return Column(
      children: [
        _buildDropdownSearch(
          title: 'Ayah',
          tipe: 'ayah',
          dropdownKey: controller.ayahDropdownKey,
        ),
        const SizedBox(height: 16),
        _buildDropdownSearch(
          title: 'Ibu',
          tipe: 'ibu',
          dropdownKey: controller.ibuDropdownKey,
        ),
        const SizedBox(height: 16),
        _buildDropdownSearch(
          title: 'Wali',
          tipe: 'wali',
          dropdownKey: controller.waliDropdownKey,
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

  Widget _buildDropdownSearch({
    required String title,
    required String tipe,
    required GlobalKey<DropdownSearchState<Datum>> dropdownKey,
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
          key: dropdownKey,
          selectedItem: tipe == 'ayah'
              ? controller.selectedAyah.value
              : tipe == 'ibu'
              ? controller.selectedIbu.value
              : controller.selectedWali.value,
          compareFn: (item1, item2) => item1.id == item2.id,
          items: (f, cs) {
            return controller.loadOrtuByTipe(tipe, f);
          },
          itemAsString: (Datum u) => u.nama ?? '',
          autoValidateMode: AutovalidateMode.onUserInteraction,
          onSelected: (Datum? selectedItem) {
            if (tipe == 'ayah') controller.selectedAyah.value = selectedItem;
            if (tipe == 'ibu') controller.selectedIbu.value = selectedItem;
            if (tipe == 'wali') controller.selectedWali.value = selectedItem;

            controller.ortuFormKey.currentState?.validate();
          },
          onBeforePopupOpening: (selectedItem) {
            FocusManager.instance.primaryFocus?.unfocus();
            return Future.value(true);
          },
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: 'Pilih $title...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[400],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: Colors.grey[400],
                size: 20,
              ),
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          popupProps: PopupProps.modalBottomSheet(
            modalBottomSheetProps: ModalBottomSheetProps(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            showSearchBox: true,
            searchDelay: const Duration(milliseconds: 500),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari $title...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Colors.deepPurpleAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.deepPurpleAccent),
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
                              Icons.person_search_rounded,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Data $title tidak ditemukan',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
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
                child: CircularProgressIndicator(
                  color: Colors.deepPurpleAccent,
                  strokeWidth: 3,
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
            listViewProps: ListViewProps(
              padding: EdgeInsets.fromLTRB(
                0,
                0,
                0,
                MediaQuery.of(Get.context!).padding.bottom + 20,
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
            if (controller.selectedAyah.value == null &&
                controller.selectedIbu.value == null &&
                controller.selectedWali.value == null) {
              return 'Minimal satu orang tua harus dipilih';
            }
            return null;
          },
          suffixProps: DropdownSuffixProps(
            clearButtonProps: ClearButtonProps(
              isVisible: true,
              icon: Icon(
                Icons.clear_rounded,
                size: 20,
                color: Colors.grey[500],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTahapHafalanSectionForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tahap Hafalan',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          dropdownColor: Colors.white,
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
              return 'Tahap Hafalan tidak boleh kosong';
            }
            return null;
          },
          decoration: InputDecoration(
            fillColor: Colors.grey[50],
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.deepPurpleAccent),
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: const [
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
                    'Password untuk santri',
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(
                  () => TextFormField(
                    controller: controller.passwordC,
                    key: controller.passwordFieldKey,
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
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.deepPurpleAccent,
                        ),
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
                  controller.isPasswordVisible.value = true;
                  controller.passwordFieldKey.currentState?.validate();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
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
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({super.key, required this.controller});

  final TambahSantriController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: !controller.isSaveProfileLoading.value
            ? () {
                bool isProfileValid =
                    controller.profileFormKey.currentState?.validate() ?? false;
                bool isOrtuValid =
                    controller.ortuFormKey.currentState?.validate() ?? false;

                if (isProfileValid && isOrtuValid) {
                  controller.addSantri();
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
                'Daftarkan Santri',
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
