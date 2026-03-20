import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../utils/toast_utils.dart';
import '../controllers/tambah_ortu_controller.dart';

class TambahOrtuView extends GetView<TambahOrtuController> {
  const TambahOrtuView({super.key});
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
                  'Tambah Orang Tua Baru',
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
                                  Stack(
                                    children: [
                                      Container(
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
                                                child:
                                                    controller
                                                            .pickedImage
                                                            .value !=
                                                        null
                                                    ? Image.file(
                                                        File(
                                                          controller
                                                              .pickedImage
                                                              .value!
                                                              .path,
                                                        ),
                                                        fit: BoxFit.cover,
                                                      )
                                                    : CachedNetworkImage(
                                                        imageUrl: controller
                                                            .getImageUrl(
                                                              controller
                                                                  .defaultPhotoProfile
                                                                  .value,
                                                            ),
                                                        fit: BoxFit.cover,
                                                        placeholder:
                                                            (
                                                              context,
                                                              url,
                                                            ) => Container(
                                                              color: Colors
                                                                  .grey[300],
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 40,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => Container(
                                                              color: Colors
                                                                  .grey[300],
                                                              child: const Icon(
                                                                Icons.person,
                                                                size: 40,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                            ),
                                                      ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag: 'foto-profil',
                                            child: ClipOval(
                                              child:
                                                  controller
                                                          .pickedImage
                                                          .value !=
                                                      null
                                                  ? Image.file(
                                                      File(
                                                        controller
                                                            .pickedImage
                                                            .value!
                                                            .path,
                                                      ),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : CachedNetworkImage(
                                                      imageUrl: controller
                                                          .getImageUrl(
                                                            controller
                                                                .defaultPhotoProfile
                                                                .value,
                                                          ),
                                                      fit: BoxFit.cover,
                                                      placeholder:
                                                          (
                                                            context,
                                                            url,
                                                          ) => Container(
                                                            color: Colors
                                                                .grey[300],
                                                            child: const Icon(
                                                              Icons.person,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                      errorWidget:
                                                          (
                                                            context,
                                                            url,
                                                            error,
                                                          ) => Container(
                                                            color: Colors
                                                                .grey[300],
                                                            child: const Icon(
                                                              Icons.person,
                                                              size: 40,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                          ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Obx(
                                        () =>
                                            controller.pickedImage.value != null
                                            ? Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    controller.deleteImage();
                                                  },
                                                  child: Container(
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.white,
                                                        width: 2,
                                                      ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withValues(
                                                                alpha: 0.2,
                                                              ),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            2,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox.shrink(),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 16),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed:
                                              controller.isUploadingImage.value
                                              ? null
                                              : () {
                                                  FocusManager
                                                      .instance
                                                      .primaryFocus
                                                      ?.unfocus();
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
                    GetBuilder<TambahOrtuController>(
                      builder: (context) {
                        return Form(
                          key: controller.profileFormKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 16),

                              // Email & Password
                              _buildEmailPasswordForm(),
                              const SizedBox(height: 24),

                              // Personal Information
                              _buildPersonalInfoSectionForm(),
                              const SizedBox(height: 24),

                              // Reset and Save Button
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    flex: 5,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        controller.resetForm();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Reset Form',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    flex: 7,
                                    child: SaveProfileButton(
                                      controller: controller,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 50),
                            ],
                          ),
                        );
                      },
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

  Widget _buildEmailPasswordForm() {
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            controller: controller.emailC,
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
                borderSide: BorderSide(color: Colors.deepPurpleAccent),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
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
                  key: controller.passwordFieldKey,
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
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (controller.passwordC.text.isEmpty &&
                        (value == null || value.isEmpty)) {
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
                  controller.passwordC.text = controller.generatePassword();
                  if (kDebugMode) {
                    print(controller.passwordC.text);
                  }
                  controller.passwordFieldKey.currentState?.validate();
                },
                child: Text('Generate'),
              ),
            ],
          ),
        ],
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
    );
  }
}

class SaveProfileButton extends StatelessWidget {
  const SaveProfileButton({super.key, required this.controller});

  final TambahOrtuController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.isSaveProfileLoading.value
            ? null
            : () {
                FocusManager.instance.primaryFocus?.unfocus();
                if (controller.profileFormKey.currentState!.validate() &&
                    !controller.isUploadingImage.value) {
                  controller.addOrtu(
                    controller.pickedImage.value,
                    controller.emailC.text,
                    controller.passwordC.text,
                    controller.namaC.text,
                    controller.noHpC.text,
                    controller.jenisKelaminC.text,
                    controller.tipeC.text,
                    controller.alamatC.text,
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
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: controller.isSaveProfileLoading.value
            ? Text('Menyimpan...')
            : Text(
                'Daftarkan Orang Tua',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
      ),
    );
  }
}
