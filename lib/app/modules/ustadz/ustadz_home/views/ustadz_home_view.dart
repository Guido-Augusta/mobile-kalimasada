import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../controllers/ustadz_home_controller.dart';

class UstadzHomeView extends GetView<UstadzHomeController> {
  const UstadzHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            controller.getUstadz();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  bottom: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: 30),
                    _buildWelcomeCard(context),
                    const SizedBox(height: 25),
                    _buildFeatureCards(context),
                    const SizedBox(height: 25),
                    _buildIslamicQuoteSlider(context),
                    const SizedBox(height: 25),
                    _buildIslamicDecoration(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Obx(
          () => Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(controller.fotoProfil.value),
              onBackgroundImageError: (_, _) {},
              child: controller.fotoProfil.value.isEmpty
                  ? Icon(Icons.person, size: 28, color: Colors.deepPurpleAccent)
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assalamualaikum,',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 2),
              Obx(
                () => Text(
                  controller.ustadz.value?.nama ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
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
                          style: GoogleFonts.poppins(color: Colors.grey[600]),
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
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.logout_rounded, color: Colors.red, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Text(
                        'Dashboard ${controller.ustadz.value?.jenisKelamin == 'L' ? 'Ustadz' : 'Ustadzah'}',
                        style: GoogleFonts.poppins(
                          fontSize: controller.ustadz.value?.jenisKelamin == 'L'
                              ? 22
                              : 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Kelola Santri dengan Mudah',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.dashboard_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIslamicQuoteSlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Motivasi Islami',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.format_quote_rounded,
                      color: Colors.deepPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Obx(
                        //   () => Align(
                        //     alignment: Alignment.centerRight,
                        //     child: Text(
                        //       controller.islamicQuotes[controller
                        //           .currentIndex
                        //           .value]['quote']!,
                        //       style: GoogleFonts.amiri(
                        //         fontSize: 22,
                        //         color: Colors.deepPurple[800],
                        //         fontWeight: FontWeight.w600,
                        //         height: 1.5,
                        //       ),
                        //       textAlign: TextAlign.right,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.islamicQuotes[controller
                                .currentIndex
                                .value]['translation']!,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(
                          () => Text(
                            controller.islamicQuotes[controller
                                .currentIndex
                                .value]['source']!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    controller.islamicQuotes.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: controller.currentIndex.value == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: controller.currentIndex.value == index
                            ? Colors.deepPurple
                            : Colors.deepPurple.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      controller.currentIndex.value =
                          (controller.currentIndex.value -
                              1 +
                              controller.islamicQuotes.length) %
                          controller.islamicQuotes.length;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            color: Colors.deepPurple,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Sebelumnya',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      controller.currentIndex.value =
                          (controller.currentIndex.value + 1) %
                          controller.islamicQuotes.length;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Selanjutnya',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.deepPurple,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIslamicDecoration(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.1),
            Colors.teal.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mosque, color: Colors.green, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pondok Kalimasada',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      'Menuntut ilmu dengan penuh keikhlasan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'طَلَبُ الْعِلْمِ فَرِيْضَةٌ عَلَى كُلِّ مُسْلِمٍ',
              style: GoogleFonts.amiri(
                fontSize: 18,
                color: Colors.green[800],
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Menuntut ilmu itu wajib atas setiap Muslim',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitur Utama',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.deepPurple[800],
          ),
        ),
        const SizedBox(height: 15),
        InkWell(
          onTap: () {
            Get.toNamed('/daftar-santri');
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Kelola Data',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Daftar Santri',
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Lihat dan kelola data santri',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.toNamed('/alquran');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.deepPurple,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Al-Qur\'an',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.deepPurple[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Daftar Surah',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: InkWell(
                onTap: () {
                  Get.toNamed('/peringkat');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.leaderboard_outlined,
                          color: Colors.orange,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Peringkat',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.deepPurple[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Santri',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
