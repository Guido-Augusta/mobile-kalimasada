import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fullscreen_image_viewer/fullscreen_image_viewer.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../data/models/daftar_ortu.dart';
import '../../../../utils/toast_utils.dart';
import '../controllers/tambah_santri_controller.dart';

class TambahSantriView extends GetView<TambahSantriController> {
  const TambahSantriView({super.key});
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
                  'Tambah Santri Baru',
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
                    GetBuilder<TambahSantriController>(
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

                              // Parents Information
                              _buildParentsSectionForm(),
                              const SizedBox(height: 24),

                              // Tahap Hafalan Information
                              _buildTahapHafalanSectionForm(),
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

  Container _buildEmailPasswordForm() {
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
                  key: controller.passwordFieldKey,
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
          TextFormField(
            controller: controller.tanggalLahirC,
            readOnly: true,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Tanggal lahir tidak boleh kosong';
              }
              return null;
            },
            onTap: () {
              controller.selectDate(Get.context!);
            },
            decoration: InputDecoration(
              hintText: 'dd/mm/yyyy',
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
    );
  }

  Widget _buildParentsSectionForm() {
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
      child: Form(
        key: controller.ortuFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SearchField Ayah
            buildOrtuSearchField(
              title: 'Ayah',
              isSearching: controller.isSearching,
              tipe: 'ayah',
              formKey: controller.ayahDropdownKey,
            ),

            const SizedBox(height: 24),

            // SearchField Ibu
            buildOrtuSearchField(
              title: 'Ibu',
              isSearching: controller.isSearching,
              tipe: 'ibu',
              formKey: controller.ibuDropdownKey,
            ),

            const SizedBox(height: 24),

            // SearchField Wali
            buildOrtuSearchField(
              title: 'Wali',
              isSearching: controller.isSearching,
              tipe: 'wali',
              formKey: controller.waliDropdownKey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTahapHafalanSectionForm() {
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
    );
  }

  Widget buildOrtuSearchField({
    required String title,
    required RxBool isSearching,
    required String tipe,
    required GlobalKey<DropdownSearchState<Datum>> formKey,
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
          key: formKey,
          mode: Mode.form,
          compareFn: (item1, item2) {
            return item1.id == item2.id;
          },
          items: (f, cs) {
            return controller.loadOrtuByTipe(tipe, f);
          },
          itemAsString: (Datum u) => u.nama ?? '',
          autoValidateMode: AutovalidateMode.onUserInteraction,
          onChanged: (Datum? selectedItem) {
            if (selectedItem != null) {
              if (kDebugMode) {
                print('Selected ID: ${selectedItem.id}');
                print('Selected Name: ${selectedItem.nama}');
              }

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
            if (controller.selectedAyah.value == null &&
                controller.selectedIbu.value == null &&
                controller.selectedWali.value == null) {
              return 'Minimal satu orang tua harus dipilih';
            }
            return null;
          },
          suffixProps: DropdownSuffixProps(
            dropdownButtonProps: DropdownButtonProps(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            clearButtonProps: ClearButtonProps(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
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
                  controller.addSantri(
                    controller.pickedImage.value,
                    controller.emailC.text,
                    controller.passwordC.text,
                    controller.namaC.text,
                    controller.noIndukC.text,
                    controller.noHpC.text,
                    controller.jenisKelaminC.text,
                    controller.tanggalLahirC.text,
                    controller.alamatC.text,
                    controller.selectedAyah.value,
                    controller.selectedIbu.value,
                    controller.selectedWali.value,
                    controller.tahapHafalanC.text,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: controller.isSaveProfileLoading.value
            ? Text('Menyimpan...')
            : Text('Daftarkan Santri'),
      ),
    );
  }
}
