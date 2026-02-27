import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../data/models/daftar_ortu.dart';
import '../../../data/models/santri.dart';
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
        appBar: (!isLoading && santri == null)
            ? AppBar(
                title: const Text(
                  'Edit Santri',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Colors.deepPurpleAccent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
              )
            : null,
        body: () {
          // Data kosong
          if (!isLoading && santri == null) {
            return RefreshIndicator(
              onRefresh: () async {
                controller.getSantriDetail();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Data santri tidak ditemukan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tarik ke bawah untuk refresh',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              controller.getSantriDetail();
            },
            child: CustomScrollView(
              slivers: [
                // Custom App Bar with Gradient Background
                SliverAppBar(
                  centerTitle: true,
                  title: Text(
                    'Edit Santri',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                  expandedHeight: 180,
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
                            const SizedBox(height: 40),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Profile Picture
                                    Skeletonizer(
                                      enabled: controller.isLoading.value,
                                      child: Container(
                                        width: 100,
                                        height: 100,
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
                                        child: GestureDetector(
                                          onTap: () {
                                            FullscreenImageViewer.open(
                                              context: context,
                                              child: Hero(
                                                tag: 'foto-profil',
                                                child: CachedNetworkImage(
                                                  imageUrl: controller
                                                      .getImageUrl(
                                                        controller
                                                            .fotoProfil
                                                            .value,
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
                                                  errorWidget:
                                                      (
                                                        context,
                                                        url,
                                                        error,
                                                      ) => Container(
                                                        color: Colors.grey[300],
                                                        child: const Icon(
                                                          Icons.person,
                                                          size: 40,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag: 'foto-profil',
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: controller
                                                    .getImageUrl(
                                                      controller
                                                          .fotoProfil
                                                          .value,
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
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                          color:
                                                              Colors.grey[300],
                                                          child: const Icon(
                                                            Icons.person,
                                                            size: 40,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 16),
                                    Flexible(
                                      child: Skeletonizer(
                                        effect: ShimmerEffect(
                                          baseColor: Colors.orangeAccent,
                                          highlightColor: Colors.orange[300]!,
                                        ),
                                        enabled: controller.isLoading.value,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _showEditPhotoProfileBottomSheet();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.orangeAccent,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            'Upload Foto',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
                      // Edit Email/Password Button
                      EditEmailPasswordButton(controller: controller),
                      Form(
                        key: controller.profileFormKey,
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Personal Information
                            _buildEditPersonalInfoSection(
                              santri ?? controller.santriDummy,
                            ),
                            const SizedBox(height: 24),

                            // Parents Information
                            _buildEditParentsSection(
                              santri ?? controller.santriDummy,
                            ),
                            const SizedBox(height: 24),

                            // Tahap Hafalan Information
                            _buildEditTahapHafalanSection(
                              santri ?? controller.santriDummy,
                            ),
                            const SizedBox(height: 24),

                            // Save Button
                            Row(
                              children: [
                                const Spacer(),
                                SizedBox(
                                  width:
                                      (MediaQuery.of(context).size.width - 32) *
                                      0.5,
                                  child: SaveProfileButton(
                                    controller: controller,
                                    formKey: controller.profileFormKey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 50,
                            ), // Space for bottom buttons
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
              },
            ),
            ListTile(
              minTileHeight: 40,
              leading: Icon(Icons.photo_outlined),
              title: Text('Galeri'),
              onTap: () {
                controller.pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditPersonalInfoSection(Santri santri) {
    return Skeletonizer(
      enabled: controller.isLoading.value,
      child: Container(
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
            Text(
              'Nomor Induk',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Colors.black),
              controller: controller.noIndukC,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor Induk tidak boleh kosong';
                }
                if (!value.isNumericOnly) {
                  return 'Nomor Induk harus berupa angka';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: 'Masukkan Nomor Induk',
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
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              keyboardType: TextInputType.phone,
              style: TextStyle(color: Colors.black),
              controller: controller.noHpC,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
              onTap: () => controller.selectDate(Get.context!),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: controller.tanggalLahirC,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
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
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              initialValue: controller.jenisKelaminC.text,
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
                DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
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
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
    );
  }

  Widget _buildEditParentsSection(Santri santri) {
    return Skeletonizer(
      enabled: controller.isLoading.value,
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SearchField Ayah
            buildOrtuSearchField(
              title: 'Ayah',
              isSearching: controller.isAyahSearching,
              tipe: 'ayah',
            ),

            const SizedBox(height: 24),

            // SearchField Ibu
            buildOrtuSearchField(
              title: 'Ibu',
              isSearching: controller.isIbuSearching,
              tipe: 'ibu',
            ),

            const SizedBox(height: 24),

            // SearchField Wali
            buildOrtuSearchField(
              title: 'Wali',
              isSearching: controller.isWaliSearching,
              tipe: 'wali',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTahapHafalanSection(Santri santri) {
    return Skeletonizer(
      enabled: controller.isLoading.value,
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tahap Hafalan',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              initialValue: controller.tahapHafalanC.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tahap hafalan tidak boleh kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                fillColor: Colors.grey[50],
                filled: true,
                hintText: 'Pilih Tahap Hafalan',
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
                  value: 'Level1',
                  child: Text('Level 1 - Juz 30'),
                ),
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
        ),
      ),
    );
  }

  // Tambahkan widget ini di dalam class EditSantriView
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
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),

        DropdownSearch<Datum>(
          compareFn: (item1, item2) {
            return item1.id == item2.id;
          },
          items: (f, cs) => controller.loadOrtuByTipe(tipe, f),
          itemAsString: (Datum u) => u.nama ?? '',
          selectedItem: controller.getSelectedOrtuByTipe(tipe),
          onChanged: (Datum? selectedItem) {
            if (selectedItem != null) {
              if (kDebugMode) {
                print('Selected ID: ${selectedItem.id}');
                print('Selected Name: ${selectedItem.nama}');
              }

              // Simpan ID ke controller jika diperlukan
              if (tipe == 'ayah') {
                controller.selectedAyah.value = selectedItem;
              } else if (tipe == 'ibu') {
                controller.selectedIbu.value = selectedItem;
              } else if (tipe == 'wali') {
                controller.selectedWali.value = selectedItem;
              }
            }

            if (selectedItem == null) {
              if (tipe == 'ayah') {
                controller.selectedAyah.value = null;
              } else if (tipe == 'ibu') {
                controller.selectedIbu.value = null;
              } else if (tipe == 'wali') {
                controller.selectedWali.value = null;
              }
            }
          },
          decoratorProps: DropDownDecoratorProps(
            decoration: InputDecoration(
              hintText: 'Pilih $title...',
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.deepPurple,
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
                borderSide: BorderSide(color: Colors.deepPurple),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            showSearchBox: true,
            searchDelay: Duration(milliseconds: 500),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Cari $title...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.deepPurple),
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
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Data $title tidak ditemukan',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Coba dengan kata kunci yang berbeda',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox.shrink(),
              ),
            ),
            loadingBuilder: (context, searchEntry) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
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
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 160),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            itemBuilder: (context, item, isDisabled, isSelected) {
              return Obx(
                () => !controller.isSearching.value
                    ? ListTile(
                        title: Text(
                          item.nama ?? '',
                          style: TextStyle(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      )
                    : SizedBox.shrink(),
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
          suffixProps: DropdownSuffixProps(
            clearButtonProps: ClearButtonProps(
              isVisible: true,
              icon: const Icon(Icons.clear_rounded, size: 22),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
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
        effect: ShimmerEffect(
          baseColor: Colors.black,
          highlightColor: Colors.black54,
        ),
        child: ElevatedButton(
          onPressed: !controller.isSaveProfileLoading.value
              ? () {
                  if (kDebugMode) {
                    print(controller.selectedAyah.value);
                    print(controller.selectedIbu.value);
                    print(controller.selectedWali.value);
                    print(formKey.currentState?.validate());
                  }
                  if (formKey.currentState!.validate()) {
                    controller.updateProfileSantri(
                      controller.namaC.text,
                      controller.noIndukC.text,
                      controller.noHpC.text,
                      controller.alamatC.text,
                      controller.jenisKelaminC.text,
                      controller.tanggalLahirC.text,
                      controller.tahapHafalanC.text,
                      controller.selectedAyah.value,
                      controller.selectedIbu.value,
                      controller.selectedWali.value,
                    );
                  } else {
                    final now = DateTime.now();
                    if (controller.lastErrorShown == null ||
                        now.difference(controller.lastErrorShown!) >
                            Duration(seconds: 3)) {
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: controller.isSaveProfileLoading.value
              ? Text('Menyimpan...')
              : Text('Simpan Perubahan'),
        ),
      ),
    );
  }
}

class EditEmailPasswordButton extends StatelessWidget {
  const EditEmailPasswordButton({super.key, required this.controller});

  final EditSantriController controller;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: controller.isLoading.value,
      effect: ShimmerEffect(
        baseColor: Colors.black,
        highlightColor: Colors.black54,
      ),
      child: ElevatedButton.icon(
        onPressed: () {
          // Dialog Edit Email & Password
          _showEditEmailPasswordDialog();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: Icon(Icons.edit),
        label: Text('Edit Email/Password'),
      ),
    );
  }

  void _showEditEmailPasswordDialog() {
    controller.emailC.text = controller.santriDetail.value!.user!.email!;
    controller.passwordC.text = '';
    Get.dialog(
      barrierDismissible: false,
      Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
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
                    colors: [Colors.black, Colors.black87],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Edit Email & Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ubah email atau password Santri',
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

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Form(
                    key: controller.emailPasswordFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          validator: controller.validateEmail,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Masukkan email',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          controller: controller.emailC,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: controller.passwordC,
                                enabled: false,
                                readOnly: true,
                                obscureText: true,
                                decoration: InputDecoration(
                                  hintText: 'Password baru',
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
                                      color: Colors.deepPurpleAccent,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.red),
                                  ),
                                ),
                                autovalidateMode: AutovalidateMode.always,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Generate password baru';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Button Generate
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(100, 48),
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                controller.passwordC.text = controller
                                    .generatePassword();
                                if (kDebugMode) {
                                  print(controller.passwordC.text);
                                }

                                final formState = controller
                                    .emailPasswordFormKey
                                    .currentState;
                                if (formState != null) {
                                  formState.validate();
                                }
                              },
                              child: Text('Generate'),
                            ),
                          ],
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
                          onPressed: controller.isSaveEmailPasswordLoading.value
                              ? null
                              : () {
                                  print(controller.emailC.text);
                                  print(controller.passwordC.text);
                                  print(
                                    controller
                                        .emailPasswordFormKey
                                        .currentState!
                                        .validate(),
                                  );
                                  if (controller
                                      .emailPasswordFormKey
                                      .currentState!
                                      .validate()) {
                                    controller.updateEmailPasswordSantri(
                                      controller.emailC.text,
                                      controller.passwordC.text,
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: controller.isSaveEmailPasswordLoading.value
                                ? EdgeInsets.symmetric(vertical: 4)
                                : EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: controller.isSaveEmailPasswordLoading.value
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
}
