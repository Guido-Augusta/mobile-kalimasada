import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
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
    return Obx(() {
      return Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: () {
          return CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                centerTitle: true,
                title: Text(
                  'Edit Orang Tua',
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
                                          );
                                        },
                                        child: Hero(
                                          tag: 'foto-profil',
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
                                              errorWidget:
                                                  (context, url, error) =>
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
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Skeletonizer(
                                          effect: ShimmerEffect(
                                            baseColor: Colors.orangeAccent,
                                            highlightColor: Colors.orange[300]!,
                                          ),
                                          enabled: controller.isLoading.value,
                                          child: ElevatedButton(
                                            onPressed:
                                                controller
                                                    .isUploadingImage
                                                    .value
                                                ? null
                                                : () {
                                                    controller.alamatFocusNode
                                                        .unfocus();
                                                    FocusScope.of(
                                                      Get.context!,
                                                    ).unfocus();
                                                    _showEditPhotoProfileBottomSheet();
                                                  },
                                            style: ElevatedButton.styleFrom(
                                              disabledBackgroundColor:
                                                  Colors.grey[400],
                                              disabledForegroundColor:
                                                  Colors.white,
                                              backgroundColor:
                                                  Colors.orangeAccent,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text(
                                              controller.isUploadingImage.value
                                                  ? 'Uploading...'
                                                  : 'Upload Foto',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ),
                                        // const SizedBox(height: 6),
                                        const Text(
                                          '(Opsional)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
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
                          _buildPersonalInfoSectionForm(),
                          const SizedBox(height: 24),

                          // Save Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SaveProfileButton(
                                controller: controller,
                                formKey: controller.profileFormKey,
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

  Widget _buildPersonalInfoSectionForm() {
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
              'Nomor HP',
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
              controller: controller.noHpC,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Nomor HP tidak boleh kosong';
                }
                if (value.isNotEmpty && !value.isNumericOnly) {
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
              'Tipe Orang Tua',
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
              initialValue: controller.tipeC.text,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Tipe orang tua tidak boleh kosong';
                }
                return null;
              },
              decoration: InputDecoration(
                fillColor: Colors.grey[50],
                filled: true,
                hintText: 'Pilih Tipe Orang Tua',
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
                DropdownMenuItem(value: 'Ayah', child: Text('Ayah')),
                DropdownMenuItem(value: 'Ibu', child: Text('Ibu')),
                DropdownMenuItem(value: 'Wali', child: Text('Wali')),
              ],
              onChanged: (value) {
                controller.tipeC.text = value!;
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
              focusNode: controller.alamatFocusNode,
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
}

class EditEmailPasswordButton extends StatelessWidget {
  const EditEmailPasswordButton({super.key, required this.controller});

  final EditOrtuController controller;

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
    controller.emailC.text = controller.ortuDetail.value!.user!.email!;
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
                      'Ubah email atau password Orang Tua',
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
                                    controller.updateEmailPasswordOrtu(
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
      () => Skeletonizer(
        enabled: controller.isLoading.value,
        effect: ShimmerEffect(
          baseColor: Colors.black,
          highlightColor: Colors.black54,
        ),
        child: ElevatedButton(
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
