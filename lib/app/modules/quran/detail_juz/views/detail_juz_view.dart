import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/detail_juz.dart';
import 'package:mobile_kalimasada/app/widgets/custom_animation_search_bar.dart';
import 'package:mobile_kalimasada/app/utils/quran_utils.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../controllers/detail_juz_controller.dart';

class DetailJuzView extends GetView<DetailJuzController> {
  const DetailJuzView({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: SafeArea(
            child: Obx(() {
              final juzData = controller.detailJuz.value?.data;
              final halamanList = juzData?.halaman ?? [];
              final firstHalaman = halamanList.isNotEmpty
                  ? halamanList.first
                  : 0;
              final lastHalaman = halamanList.isNotEmpty ? halamanList.last : 0;

              return CustomAnimationSearchBar(
                controller: TextEditingController(),
                onSubmitted: (text) {
                  final val = int.tryParse(text);
                  if (val == null) return;
                  final ayatList = juzData?.ayat ?? [];
                  final targetIndex = ayatList.indexWhere(
                    (a) => a.halaman == val,
                  );
                  if (targetIndex == -1) return;
                  controller.listC.animateToItem(
                    index: targetIndex,
                    scrollController: controller.scrollC,
                    alignment: 0,
                    duration: (estimatedDistance) =>
                        const Duration(milliseconds: 1000),
                    curve: (estimatedDistance) => Curves.fastLinearToSlowEaseIn,
                  );
                },
                centerTitle: 'Detail Juz',
                hintText: 'Cari halaman ($firstHalaman-$lastHalaman)...',
                keyboardType: TextInputType.number,
                minValue: firstHalaman,
                maxValue: lastHalaman,
                minValueErrorMessage:
                    'Halaman tidak ada di juz ini ($firstHalaman-$lastHalaman)',
                maxValueErrorMessage:
                    'Halaman tidak ada di juz ini ($firstHalaman-$lastHalaman)',
                showSearchIcon: !controller.isLoading.value,
              );
            }),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Obx(() {
          if (controller.detailJuz.value == null) {
            return const SizedBox.shrink();
          }
          return AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: controller.isFabVisible.value
                ? Offset.zero
                : const Offset(2, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'juz_up',
                  backgroundColor: Colors.deepPurpleAccent,
                  mini: true,
                  onPressed: () {
                    controller.scrollC.animateTo(
                      0,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.fastLinearToSlowEaseIn,
                    );
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_up_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height:
                      (MediaQuery.of(Get.context!).size.height -
                          MediaQuery.of(Get.context!).padding.top -
                          AppBar().preferredSize.height) *
                      0.05,
                ),
              ],
            ),
          );
        }),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildSkeleton();
          }

          if (controller.detailJuz.value == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      size: 48,
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Data tidak ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                if (controller.isFabVisible.value) {
                  controller.isFabVisible.value = false;
                }
              } else if (notification.direction == ScrollDirection.forward) {
                if (!controller.isFabVisible.value) {
                  controller.isFabVisible.value = true;
                }
              }
              return true;
            },
            child: CustomScrollView(
              controller: controller.scrollC,
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildJuzHeaderCard(context)),

                // Ayat List
                if (controller.detailJuz.value?.data?.ayat.isEmpty ?? true)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.format_list_numbered_outlined,
                              size: 48,
                              color: Colors.deepPurpleAccent.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada ayat',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SuperSliverList(
                    listController: controller.listC,
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ayatList =
                            controller.detailJuz.value?.data?.ayat ?? [];
                        final ayat = ayatList[index];
                        final showSurahSeparator =
                            index == 0 ||
                            ayat.surah?.nomor !=
                                ayatList[index - 1].surah?.nomor;
                        return _buildAyatCard(
                          ayat,
                          showSurahSeparator: showSurahSeparator,
                        );
                      },
                      childCount: controller.detailJuz.value?.data?.ayat.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Header Card ───────────────────────────────────────────────────────────────

  Widget _buildJuzHeaderCard(BuildContext context) {
    final juzData = controller.detailJuz.value?.data;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -20,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              children: [
                // ── Top row: Juz name info ─────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Juz number badge
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${juzData?.juz ?? '-'}',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Juz ${juzData?.juz ?? '-'}',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Mulai dari ${juzData?.mulaiDari?.surah?.namaLatin ?? '-'} (${juzData?.mulaiDari?.ayat ?? '-'})',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge info
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${juzData?.totalAyat ?? 0} Ayat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Divider
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),

                const SizedBox(height: 12),

                // ── Halaman info ──────────────────────────────────────────
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Halaman ${juzData?.halaman.isNotEmpty == true ? '${juzData!.halaman.first} - ${juzData.halaman.last}' : '-'}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ayat Card ─────────────────────────────────────────────────────────────────

  Widget _buildAyatCard(Ayat? ayat, {bool showSurahSeparator = false}) {
    return Column(
      children: [
        // Surah separator
        if (showSurahSeparator && ayat?.surah != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.withValues(alpha: 0.08),
                  Colors.deepPurpleAccent.withValues(alpha: 0.04),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.deepPurple.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${ayat?.surah?.nomor ?? ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ayat?.surah?.namaLatin ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple[700],
                    ),
                  ),
                ),
                Text(
                  ayat?.surah?.nama ?? '',
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),

        // Ayat card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            color: Colors.white,
            elevation: 1,
            shadowColor: Colors.black.withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ayat number & Surah info
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${ayat?.nomorAyat ?? ''}',
                            style: TextStyle(
                              color: Colors.deepPurpleAccent[700],
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        ayat?.surah?.namaLatin ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      // Halaman info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Hal. ${ayat?.halaman ?? '-'}',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Arabic Text
                  if (ayat?.arab != null && ayat!.arab!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${ayat.arab!} ${QuranUtils.getAyahEndSymbol(ayat.nomorAyat!)}',
                          style: GoogleFonts.amiri(fontSize: 22, height: 2.2),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),

                  // Latin Text
                  if (ayat?.latin != null && ayat!.latin!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        ayat.latin!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),

                  // Translation
                  if (ayat?.terjemah != null && ayat!.terjemah!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          ayat.terjemah!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.4,
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
    );
  }

  // ── Skeleton Loading ────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          // ── Skeleton Header Card ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Skeletonizer(
              effect: ShimmerEffect(
                baseColor: Colors.white.withValues(alpha: 0.2),
                highlightColor: Colors.white.withValues(alpha: 0.4),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepPurpleAccent, Colors.deepPurple[700]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Bone.circle(size: 52),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Bone.text(
                                  words: 1,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Bone.text(
                                  words: 3,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Bone(
                            width: 70,
                            height: 28,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.2),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Bone.icon(size: 16),
                          const SizedBox(width: 6),
                          Bone.text(
                            words: 2,
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Skeleton Ayat Cards ──────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSkeletonAyatCard(),
              childCount: 5,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSkeletonAyatCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nomor & surah info row
              Row(
                children: [
                  Bone(
                    width: 32,
                    height: 32,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(width: 8),
                  Bone.text(words: 2, style: const TextStyle(fontSize: 11)),
                  const Spacer(),
                  Bone(
                    width: 50,
                    height: 20,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Arabic text placeholder
              Align(
                alignment: Alignment.centerRight,
                child: Bone.multiText(
                  lines: 1,
                  style: GoogleFonts.amiri(fontSize: 22, height: 2.2),
                ),
              ),
              const SizedBox(height: 12),

              // Latin text placeholder
              Bone.multiText(
                lines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),

              // Translation placeholder
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Bone.multiText(
                  lines: 2,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
