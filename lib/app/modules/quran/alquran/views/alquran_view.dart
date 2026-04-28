import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_surah.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_juz.dart' as juz_model;
import 'package:skeletonizer/skeletonizer.dart';
import '../controllers/alquran_controller.dart';

class AlquranView extends GetView<AlquranController> {
  const AlquranView({super.key});

  static final _purple = Colors.deepPurple[700]!;
  static const _purpleLight = Colors.deepPurpleAccent;
  static const _orange = Colors.orange;
  static const _orangeLight = Colors.orangeAccent;
  static const _bgColor = Color(0xFFF1F5F9);

  @override
  Widget build(BuildContext context) {
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _bgColor,
        body: SafeArea(
          top: false,
          child: RefreshIndicator(
            onRefresh: () async => controller.refreshData(),
            color: Colors.deepPurpleAccent,
            backgroundColor: Colors.white,
            child: Obx(
              () => CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildHeader(context, canPop),
                  _buildSearchBar(),
                  _buildTabBar(),
                  Obx(() {
                    final isLoading = controller.selectedTab.value == 0
                        ? controller.isLoadingSurah.value
                        : controller.isLoadingJuz.value;

                    if (isLoading && controller.totalCount == 0) {
                      return Skeletonizer.sliver(
                        enabled: true,
                        child: controller.selectedTab.value == 0
                            ? _buildSurahSkeleton()
                            : _buildJuzSkeleton(),
                      );
                    }

                    if (controller.totalCount == 0) return _buildEmpty();

                    return controller.selectedTab.value == 0
                        ? _buildSurahList()
                        : _buildJuzList();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, bool canPop) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20,
          bottom: 20,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [_purpleLight, _purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Top row: back button + title
            Row(
              children: [
                if (canPop)
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                if (canPop) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: canPop
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Al-Qur\'an',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Membaca & Mendengarkan Al-Qur\'an',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: controller.searchController,
            onChanged: (v) => controller.searchQuery.value = v,
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: controller.selectedTab.value == 0
                  ? 'Cari surah...'
                  : 'Cari juz...',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              prefixIcon: Icon(Icons.search_rounded, color: _purple, size: 22),
              suffixIcon: Obx(() {
                if (controller.searchQuery.value.isNotEmpty) {
                  return IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.grey[500],
                      size: 20,
                    ),
                    onPressed: () {
                      controller.searchQuery.value = '';
                      controller.searchController.clear();
                    },
                  );
                }
                return const SizedBox.shrink();
              }),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Tab Bar ──────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [_buildTabItem(0, 'Surah'), _buildTabItem(1, 'Juz')],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTab.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? Colors.deepPurpleAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  // ── Surah List ───────────────────────────────────────────────────────
  Widget _buildSurahList() {
    if (controller.filteredSurahList.isEmpty &&
        controller.searchQuery.value.isNotEmpty) {
      return _buildNoResults();
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _surahCard(controller.filteredSurahList[index]),
          childCount: controller.filteredSurahList.length,
        ),
      ),
    );
  }

  Widget _surahCard(Datum surah) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed('/detail-surah', arguments: surah.id);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Number badge — orange accent
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _orangeLight.withValues(alpha: 0.2),
                        _orange.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${surah.nomor}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.namaLatin ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: _purple.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              surah.tempatTurun ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: _purple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${surah.totalAyat} Ayat',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arabic name
                Text(
                  surah.nama ?? '',
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _purple,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Juz List ─────────────────────────────────────────────────────────
  Widget _buildJuzList() {
    if (controller.filteredJuzList.isEmpty &&
        controller.searchQuery.value.isNotEmpty) {
      return _buildNoResults();
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _juzCard(controller.filteredJuzList[index]),
          childCount: controller.filteredJuzList.length,
        ),
      ),
    );
  }

  Widget _juzCard(juz_model.Datum juz) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.toNamed('/detail-juz', arguments: juz.juz);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Number badge — orange accent
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _orangeLight.withValues(alpha: 0.2),
                        _orange.withValues(alpha: 0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${juz.juz}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Juz ${juz.juz}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${juz.mulaiDari?.surah?.namaLatin ?? '-'} ayat ${juz.mulaiDari?.ayat ?? '-'}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Ayat count badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _purple.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${juz.totalAyat} Ayat',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _purple,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Skeleton Widgets ────────────────────────────────────────────────
  Widget _buildSurahSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _surahCard(
            Datum(
              id: 1,
              nomor: 1,
              nama: "الفاتحة",
              namaLatin: "Al-Fatihah",
              tempatTurun: "Mekah",
              totalAyat: 7,
              arti: "Pembukaan",
              deskripsi: "Surah Al-Fatihah",
              audio: "",
            ),
          ),
          childCount: 10,
        ),
      ),
    );
  }

  Widget _buildJuzSkeleton() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _juzCard(
            juz_model.Datum(
              juz: 1,
              totalAyat: 148,
              mulaiDari: juz_model.MulaiDari(
                surah: juz_model.Surah(
                  nomor: 1,
                  nama: "الفاتحة",
                  namaLatin: "Al-Baqarah",
                ),
                ayat: 1,
              ),
            ),
          ),
          childCount: 10,
        ),
      ),
    );
  }

  // ── State Widgets ────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.menu_book_rounded,
              size: 52,
              color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada data',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarik ke bawah untuk refresh',
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52,
              color: Colors.deepPurpleAccent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Tidak ada hasil yang cocok',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coba cari dengan kata kunci lain',
              style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
