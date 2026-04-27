import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:mobile_kalimasada/app/data/models/detail_hafalan_surah.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/widgets/custom_animation_search_bar.dart';
import '../../../../utils/quran_utils.dart';
import '../controllers/detail_hafalan_surah_controller.dart';

class DetailHafalanSurahView extends GetView<DetailHafalanSurahController> {
  const DetailHafalanSurahView({super.key});

  static DetailHafalanSurahController? _cached;

  @override
  DetailHafalanSurahController get controller {
    if (Get.isRegistered<DetailHafalanSurahController>()) {
      _cached = Get.find<DetailHafalanSurahController>();
      return _cached!;
    }
    return _cached!;
  }

  Stream<PositionData> get positionDataStream =>
      rx.Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        controller.audioPlayer.positionStream,
        controller.audioPlayer.bufferedPositionStream,
        controller.audioPlayer.durationStream,
        (position, bufferedPosition, duration) => PositionData(
          position: position,
          bufferedPosition: bufferedPosition,
          duration: duration ?? Duration.zero,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Obx(
            () => CustomAnimationSearchBar(
              controller: controller.searchC,
              onSubmitted: (text) {
                final val = int.tryParse(text);
                if (val == null) return;
                controller.scrollToAyat(val);
              },
              centerTitle: 'Detail Hafalan',
              hintText:
                  'Cari ayat (1-${controller.surahInfo.value?.jumlahAyat ?? 0})...',
              keyboardType: TextInputType.number,
              maxValue: controller.surahInfo.value?.jumlahAyat,
              showSearchIcon: !controller.isSurahInfoLoading.value,
            ),
          ),
        ),
      ),

      // ── 3 Action Buttons (bottom bar) ────────────────────────────────────────
      bottomNavigationBar: Obx(() {
        if (!AuthService.to.isUstadz) {
          return const SizedBox.shrink();
        }
        if (controller.isSurahInfoLoading.value ||
            controller.isCurrentLoading) {
          return const SizedBox.shrink();
        }
        if (controller.currentDetail == null &&
            controller.surahInfo.value == null) {
          return const SizedBox.shrink();
        }
        return _buildActionBar(context);
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Obx(() {
        if (controller.isSurahInfoLoading.value ||
            controller.isCurrentLoading) {
          return const SizedBox.shrink();
        }
        if (controller.surahInfo.value == null &&
            controller.currentDetail == null) {
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
                heroTag: 'up',
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
              const SizedBox(height: 8),
              if (!AuthService.to.isUstadz) ...[
                StreamBuilder<PlayerState>(
                  stream: controller.audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;

                    if (processingState == ProcessingState.loading ||
                        processingState == ProcessingState.buffering) {
                      return FloatingActionButton(
                        heroTag: 'play_pause',
                        backgroundColor: Colors.deepPurpleAccent,
                        mini: true,
                        onPressed: null,
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                      );
                    }

                    if (!(playing ?? false)) {
                      return FloatingActionButton(
                        heroTag: 'play_pause',
                        backgroundColor: Colors.deepPurpleAccent,
                        mini: true,
                        onPressed: controller.audioPlayer.play,
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return FloatingActionButton(
                        heroTag: 'play_pause',
                        backgroundColor: Colors.deepPurpleAccent,
                        mini: true,
                        onPressed: controller.audioPlayer.pause,
                        child: const Icon(
                          Icons.pause_rounded,
                          color: Colors.white,
                        ),
                      );
                    } else {
                      return FloatingActionButton(
                        heroTag: 'play_pause',
                        backgroundColor: Colors.deepPurpleAccent,
                        mini: true,
                        onPressed: () {
                          controller.audioPlayer.seek(Duration.zero);
                          controller.audioPlayer.play();
                        },
                        child: const Icon(
                          Icons.replay_rounded,
                          color: Colors.white,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),
              ],
              FloatingActionButton(
                heroTag: 'down',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                onPressed: () {
                  final ayatLength = controller.currentDetail?.ayat.length ?? 0;
                  if (ayatLength > 0 && controller.listC.isAttached) {
                    final targetIndex = controller.currentLastChecked;
                    if (targetIndex >= 0 && targetIndex < ayatLength) {
                      controller.listC.animateToItem(
                        index: targetIndex,
                        scrollController: controller.scrollC,
                        alignment: 0,
                        duration: (estimatedDistance) =>
                            const Duration(milliseconds: 1000),
                        curve: (estimatedDistance) =>
                            Curves.fastLinearToSlowEaseIn,
                      );
                    }
                  }
                },
                child: const Icon(
                  Icons.keyboard_arrow_down_outlined,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height:
                    (MediaQuery.of(Get.context!).size.height -
                        MediaQuery.of(Get.context!).padding.top -
                        AppBar().preferredSize.height) *
                    0.1,
              ),
            ],
          ),
        );
      }),

      body: Obx(() {
        // Loading state
        if (controller.isSurahInfoLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.deepPurpleAccent),
                SizedBox(height: 16),
                Text(
                  'Memuat data...',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ],
            ),
          );
        }

        // Error state
        if (controller.currentDetail == null &&
            controller.surahInfo.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
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

        // Main content
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
              // ── Surah Info Header Card ───────────────────────────────────────
              SliverToBoxAdapter(child: _buildSurahHeaderCard(context)),

              // ── Tab Bar Mode ───────────────────────────────────────────────
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyTabBarDelegate(child: _buildTabBar()),
              ),

              // ── Progres Summary Bar ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Skeletonizer(
                  enabled: controller.isCurrentLoading,
                  child: _buildProgressSummaryBar(),
                ),
              ),

              // ── Ayat List ────────────────────────────────────────────────────
              if (controller.isCurrentLoading &&
                  (controller.currentDetail?.ayat.isEmpty ?? true))
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Skeletonizer(
                      enabled: true,
                      child: _buildAyatCard(
                        Ayat(
                          id: 0,
                          nomorAyat: index + 1,
                          arab: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                          latin: 'Bismillaahir Rahmaanir Raheem',
                          terjemah:
                              'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang.',
                          juz: 30,
                          checked: false,
                          kualitas: 'Baik',
                          keterangan: 'Lanjut',
                        ),
                      ),
                    );
                  }, childCount: 5),
                )
              else if (controller.currentDetail?.ayat.isEmpty ?? true)
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final ayat = controller.currentDetail?.ayat[index];
                    return Skeletonizer(
                      enabled: controller.isCurrentLoading,
                      child: _buildAyatCard(ayat),
                    );
                  }, childCount: controller.currentDetail?.ayat.length ?? 0),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        );
      }),
    );
  }

  // ── Surah Header Card ───────────────────────────────────────────────────────

  Widget _buildSurahHeaderCard(BuildContext context) {
    final surah = controller.surahInfo.value;
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                // ── Top row: surah name info ─────────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surah?.namaLatin ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            surah?.arti ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
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
                        '${surah?.tempatTurun?.toUpperCase() ?? ''} · ${surah?.jumlahAyat ?? 0} Ayat',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider
                Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),

                const SizedBox(height: 12),

                // ── Audio Player ─────────────────────────────────────────────
                Row(
                  children: [
                    // Play/Pause
                    StreamBuilder<PlayerState>(
                      stream: controller.audioPlayer.playerStateStream,
                      builder: (context, snapshot) {
                        final playerState = snapshot.data;
                        final processingState = playerState?.processingState;
                        final playing = playerState?.playing;

                        if (processingState == ProcessingState.loading ||
                            processingState == ProcessingState.buffering) {
                          return Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(10),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          );
                        }

                        IconData iconData;
                        VoidCallback? onTap;

                        if (!(playing ?? false)) {
                          iconData = Icons.play_circle_filled_rounded;
                          onTap = controller.audioPlayer.play;
                        } else if (processingState !=
                            ProcessingState.completed) {
                          iconData = Icons.pause_circle_filled_rounded;
                          onTap = controller.audioPlayer.pause;
                        } else {
                          iconData = Icons.replay_circle_filled_rounded;
                          onTap = () {
                            controller.audioPlayer.seek(Duration.zero);
                            controller.audioPlayer.play();
                          };
                        }

                        return GestureDetector(
                          onTap: onTap,
                          child: Icon(iconData, size: 44, color: Colors.white),
                        );
                      },
                    ),

                    const SizedBox(width: 10),

                    // Progress bar
                    Expanded(
                      child: StreamBuilder<PositionData>(
                        stream: positionDataStream,
                        builder: (context, snapshot) {
                          final positionData = snapshot.data;
                          return ProgressBar(
                            barHeight: 5,
                            baseBarColor: Colors.white.withValues(alpha: 0.3),
                            progressBarColor: Colors.white,
                            thumbColor: Colors.white,
                            bufferedBarColor: Colors.white.withValues(
                              alpha: 0.5,
                            ),
                            timeLabelTextStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            progress: positionData?.position ?? Duration.zero,
                            buffered:
                                positionData?.bufferedPosition ?? Duration.zero,
                            total: positionData?.duration ?? Duration.zero,
                            onSeek: controller.audioPlayer.seek,
                          );
                        },
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

  // ── Tab Bar ─────────────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Hafalan', Colors.deepPurpleAccent),
          _buildTabItem(1, 'Murajaah', Colors.deepPurpleAccent),
          _buildTabItem(2, 'Tahsin', Colors.deepPurpleAccent),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, Color color) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.changeTab(index);
          controller.isFabVisible.value = true;
        },
        child: Obx(() {
          final isSelected = controller.selectedTab.value == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.3)
                    : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? color : Colors.grey[500],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Progress Summary Bar ────────────────────────────────────────────────────

  Widget _buildProgressSummaryBar() {
    final ayatList = controller.currentDetail?.ayat ?? [];
    final totalAyat = ayatList.length;
    final checkedAyat = ayatList
        .where(
          (a) => a.checked == true && a.keterangan?.toLowerCase() == 'lanjut',
        )
        .length;
    final progressPct = totalAyat > 0 ? checkedAyat / totalAyat : 0.0;
    final pctStr = (progressPct * 100).toStringAsFixed(0);

    Color barColor;
    if (checkedAyat == 0) {
      barColor = Colors.red[400]!;
    } else if (checkedAyat >= totalAyat) {
      barColor = const Color(0xFF10B981);
    } else {
      barColor = Colors.orange[400]!;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres Hafalan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$checkedAyat/$totalAyat',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    TextSpan(
                      text: '  ($pctStr%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPct,
              minHeight: 7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }

  // ── Ayat Card ───────────────────────────────────────────────────────────────

  Widget _buildAyatCard(Ayat? ayat) {
    final isChecked = ayat?.checked == true;

    Color borderColor = Colors.grey[200]!;
    Color kualitasBgColor = Colors.blue[50]!;
    Color kualitasTextColor = Colors.blue[700]!;

    if (ayat?.kualitas != null) {
      final k = ayat!.kualitas!.toLowerCase();
      if (k == 'kurang') {
        kualitasBgColor = Colors.red[50]!;
        kualitasTextColor = Colors.red[700]!;
      } else if (k == 'cukup') {
        kualitasBgColor = Colors.orange[50]!;
        kualitasTextColor = Colors.orange[700]!;
      } else if (k == 'baik') {
        kualitasBgColor = Colors.teal[50]!;
        kualitasTextColor = Colors.teal[700]!;
      } else if (k == 'sangatbaik') {
        kualitasBgColor = Colors.blue[50]!;
        kualitasTextColor = Colors.blue[700]!;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isChecked ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Nomor Ayat + Checked badge ──────────────────────────────────
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${ayat?.nomorAyat}',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent[700],
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (controller.selectedTab.value == 0 &&
                    ayat?.kualitas != null &&
                    (ayat?.kualitas ?? '').isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kualitasBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ayat!.kualitas!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kualitasTextColor,
                      ),
                    ),
                  ),
                ],
                if (ayat?.keterangan != null &&
                    (ayat?.keterangan ?? '').isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: ayat!.keterangan!.toLowerCase() == 'lanjut'
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ayat.keterangan!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ayat.keterangan!.toLowerCase() == 'lanjut'
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // ── Arabic Text ─────────────────────────────────────────────────
            if (ayat?.arab != null && (ayat?.arab ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${ayat!.arab!} ${QuranUtils.getAyahEndSymbol(ayat.nomorAyat!)}',
                  style: GoogleFonts.amiri(fontSize: 22, height: 2.5),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],

            // ── Latin Text ──────────────────────────────────────────────────
            if (ayat?.latin != null && (ayat?.latin ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ayat!.latin!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],

            // ── Translation ─────────────────────────────────────────────────
            if (ayat?.terjemah != null &&
                (ayat?.terjemah ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ayat!.terjemah!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Bottom Action Bar ───────────────────────────────────────────────────────

  Widget _buildActionBar(BuildContext context) {
    final int tabIndex = controller.selectedTab.value;

    String label;
    Color color;

    if (tabIndex == 0) {
      label = 'Tambah Hafalan';
      color = Colors.deepPurpleAccent;
    } else if (tabIndex == 1) {
      label = 'Tambah Murajaah';
      color = Colors.deepPurpleAccent;
    } else {
      label = 'Tambah Tahsin';
      color = Colors.deepPurpleAccent;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tombol Play/Pause
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: StreamBuilder<PlayerState>(
                stream: controller.audioPlayer.playerStateStream,
                builder: (context, snapshot) {
                  final playerState = snapshot.data;
                  final processingState = playerState?.processingState;
                  final playing = playerState?.playing;

                  if (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) {
                    return Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: color,
                          strokeWidth: 2.5,
                        ),
                      ),
                    );
                  }

                  IconData iconData;
                  VoidCallback? onTap;

                  if (!(playing ?? false)) {
                    iconData = Icons.play_arrow_rounded;
                    onTap = controller.audioPlayer.play;
                  } else if (processingState != ProcessingState.completed) {
                    iconData = Icons.pause_rounded;
                    onTap = controller.audioPlayer.pause;
                  } else {
                    iconData = Icons.replay_rounded;
                    onTap = () {
                      controller.audioPlayer.seek(Duration.zero);
                      controller.audioPlayer.play();
                    };
                  }

                  return InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Icon(iconData, color: color, size: 28),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Tombol Tambah Progres
          Expanded(
            child: Material(
              color: color,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => _showAddProgressBottomSheet(context, tabIndex),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Sheet Form ───────────────────────────────────────────────────────

  void _showAddProgressBottomSheet(BuildContext context, int modeIndex) {
    controller.isFabVisible.value = false;
    showModalBottomSheet(
      context: context,
      builder: (_) => _AddProgressBottomSheet(
        modeIndex: modeIndex,
        totalAyat: controller.surahInfo.value?.jumlahAyat ?? 0,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}

// ── _AddProgressBottomSheet ───────────────────────────────────────────────────

class _AddProgressBottomSheet extends StatefulWidget {
  final int modeIndex;
  final int totalAyat;

  const _AddProgressBottomSheet({
    required this.modeIndex,
    required this.totalAyat,
  });

  @override
  State<_AddProgressBottomSheet> createState() =>
      _AddProgressBottomSheetState();
}

class _AddProgressBottomSheetState extends State<_AddProgressBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _ayatMulaiC = TextEditingController();
  final _ayatSelesaiC = TextEditingController();
  final _catatanC = TextEditingController();

  String? _selectedKualitas;
  String? _selectedKeterangan;
  String? _errorMessage;

  @override
  void dispose() {
    _ayatMulaiC.dispose();
    _ayatSelesaiC.dispose();
    _catatanC.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final am = int.tryParse(_ayatMulaiC.text);
    final as = int.tryParse(_ayatSelesaiC.text);

    if (am == null || as == null) return;

    if (am > as) {
      setState(
        () => _errorMessage =
            'Ayat mulai tidak boleh lebih besar dari ayat selesai',
      );
      return;
    }
    if (am < 1 || as > widget.totalAyat) {
      setState(
        () => _errorMessage = 'Ayat harus di antara 1 dan ${widget.totalAyat}',
      );
      return;
    }
    if (widget.modeIndex == 0 && _selectedKualitas == null) {
      setState(() => _errorMessage = 'Silakan pilih kualitas');
      return;
    }
    if (_selectedKeterangan == null) {
      setState(() => _errorMessage = 'Silakan pilih keterangan');
      return;
    }

    setState(() => _errorMessage = null);

    final controller = Get.find<DetailHafalanSurahController>();

    final success = await controller.saveSetoranByAyat(
      int.parse(controller.santriId),
      int.parse(controller.surahId),
      am,
      as,
      widget.modeIndex == 0 ? _selectedKualitas : null,
      _selectedKeterangan!,
      _catatanC.text,
    );

    if (success) {
      Get.back(); // tutup modal
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isRequired = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        labelStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
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
          borderSide: const BorderSide(color: Colors.deepPurpleAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        isDense: true,
      ),
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Wajib diisi';
              }
              if (!value.isNumericOnly) {
                return 'Harus berupa angka';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildKualitasChips() {
    final options = ['Kurang', 'Cukup', 'Baik', 'Sangat Baik'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _selectedKualitas == option;
        Color bgColor;
        Color textColor;
        if (option == 'Kurang') {
          bgColor = isSelected ? Colors.red[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.red[700]! : Colors.grey[700]!;
        } else if (option == 'Cukup') {
          bgColor = isSelected ? Colors.orange[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.orange[700]! : Colors.grey[700]!;
        } else if (option == 'Baik') {
          bgColor = isSelected ? Colors.teal[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.teal[700]! : Colors.grey[700]!;
        } else {
          bgColor = isSelected ? Colors.blue[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.blue[700]! : Colors.grey[700]!;
        }

        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedKualitas = option;
                  _errorMessage = null;
                });
              }
            },
            selectedColor: bgColor,
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? textColor.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeteranganChips() {
    final options = ['Mengulang', 'Lanjut'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _selectedKeterangan == option;
        Color bgColor;
        Color textColor;
        if (option == 'Mengulang') {
          bgColor = isSelected ? Colors.orange[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.orange[700]! : Colors.grey[700]!;
        } else {
          bgColor = isSelected ? Colors.green[50]! : Colors.grey[100]!;
          textColor = isSelected ? Colors.green[700]! : Colors.grey[700]!;
        }

        return Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
          ),
          child: ChoiceChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _selectedKeterangan = option;
                  _errorMessage = null;
                });
              }
            },
            selectedColor: bgColor,
            backgroundColor: Colors.grey[100],
            labelStyle: TextStyle(
              color: textColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? textColor.withValues(alpha: 0.5)
                    : Colors.transparent,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final labels = ['Hafalan', 'Murajaah', 'Tahsin'];
    final label = labels[widget.modeIndex];

    Color themeColor = Colors.deepPurpleAccent;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Progres $label',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Get.find<DetailHafalanSurahController>().santriName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Colors.blueGrey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${DateTime.now().day} ${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][DateTime.now().month - 1]} ${DateTime.now().year}',
                                style: TextStyle(
                                  color: Colors.blueGrey[600],
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.menu_book_rounded,
                                size: 12,
                                color: Colors.blueGrey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Surah ${Get.find<DetailHafalanSurahController>().surahInfo.value?.namaLatin ?? ''}',
                                  style: TextStyle(
                                    color: Colors.blueGrey[600],
                                    fontSize: 11,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _ayatMulaiC,
                      label: 'Ayat Mulai',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _ayatSelesaiC,
                      label: 'Ayat Selesai',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              if (widget.modeIndex == 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Kualitas',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                _buildKualitasChips(),
              ],
              const SizedBox(height: 16),
              Text(
                'Keterangan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              _buildKeteranganChips(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _catatanC,
                label: 'Catatan (Opsional)',
                maxLines: 3,
                isRequired: false,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Obx(() {
                  final controller = Get.find<DetailHafalanSurahController>();
                  final isLoading = controller.isSaveLoading.value;

                  return ElevatedButton(
                    onPressed: isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── _StickyTabBarDelegate ───────────────────────────────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  _StickyTabBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 60.0;

  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xFFF1F5F9), child: child);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

// ── PositionData ──────────────────────────────────────────────────────────────

class PositionData {
  const PositionData({
    required this.position,
    required this.bufferedPosition,
    required this.duration,
  });

  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}
