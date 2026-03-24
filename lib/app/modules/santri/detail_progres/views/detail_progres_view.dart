import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:mobile_kalimasada/app/data/models/detail_hafalan.dart';
import '../controllers/detail_progres_controller.dart';

class DetailProgresView extends GetView<DetailProgresController> {
  const DetailProgresView({super.key});

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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Detail Progres',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      // ── 3 Action Buttons (bottom bar) ────────────────────────────────────────
      bottomNavigationBar: Obx(() {
        if (controller.isSurahInfoLoading.value ||
            controller.isDetailProgresLoading.value) {
          return const SizedBox.shrink();
        }
        if (controller.detailProgres.value == null &&
            controller.surahInfo.value == null) {
          return const SizedBox.shrink();
        }
        return _buildActionBar(context);
      }),

      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Obx(() {
        if (controller.surahInfo.value == null &&
            controller.detailProgres.value == null) {
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
              FloatingActionButton(
                heroTag: 'play_pause',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                onPressed: () {
                  controller.audioPlayer.play();
                },
                child: StreamBuilder<PlayerState>(
                  stream: controller.audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (!(playing ?? false)) {
                      return IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => controller.audioPlayer.play(),
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: const Icon(
                          Icons.pause_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => controller.audioPlayer.pause(),
                      );
                    }
                    return IconButton(
                      onPressed: () {
                        if (processingState == ProcessingState.completed) {
                          controller.audioPlayer.seek(Duration.zero);
                          controller.audioPlayer.play();
                        }
                      },
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'down',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                onPressed: () {
                  controller.listC.animateToItem(
                    index: controller.lastCheckedAyat.value,
                    scrollController: controller.scrollC,
                    alignment: 0,
                    duration: (estimatedDistance) =>
                        const Duration(milliseconds: 1000),
                    curve: (estimatedDistance) => Curves.fastLinearToSlowEaseIn,
                  );
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
        if (controller.isSurahInfoLoading.value ||
            controller.isDetailProgresLoading.value) {
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
        if (controller.detailProgres.value == null &&
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

              // ── Progres Summary Bar ──────────────────────────────────────────
              SliverToBoxAdapter(child: _buildProgressSummaryBar()),

              // ── Ayat List ────────────────────────────────────────────────────
              if (controller.detailProgres.value?.ayat.isEmpty ?? true)
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
                    final ayat = controller.detailProgres.value?.ayat[index];
                    return _buildAyatCard(ayat);
                  }, childCount: controller.detailProgres.value?.ayat.length),
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
                              fontSize: 20,
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
                          iconData = Icons.play_circle_filled_rounded;
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

  // ── Progress Summary Bar ────────────────────────────────────────────────────

  Widget _buildProgressSummaryBar() {
    final ayatList = controller.detailProgres.value?.ayat ?? [];
    final totalAyat = ayatList.length;
    final checkedAyat = ayatList.where((a) => a.checked == true).length;
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
                      text: '  $pctStr%',
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

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? const Color(0xFF10B981) : Colors.grey[200]!,
          width: isChecked ? 1.5 : 1,
        ),
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
                if (isChecked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 13,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Hafal',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // ── Arabic Text ─────────────────────────────────────────────────
            if (ayat?.arab != null && (ayat?.arab ?? '').isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  ayat!.arab!,
                  style: GoogleFonts.amiri(fontSize: 22, height: 2.2),
                  textAlign: TextAlign.right,
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
                  color: Colors.grey[600],
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
          // Tambah Hafalan
          Expanded(
            child: _ActionButton(
              label: 'Hafalan',
              color: const Color(0xFF10B981),
              onTap: () {
                // TODO: Tambah Hafalan
              },
            ),
          ),
          const SizedBox(width: 8),
          // Murajaah
          Expanded(
            child: _ActionButton(
              label: 'Murajaah',
              color: Colors.orange[600]!,
              onTap: () {
                // TODO: Murajaah
              },
            ),
          ),
          const SizedBox(width: 8),
          // Tahsin
          Expanded(
            child: _ActionButton(
              label: 'Tahsin',
              color: Colors.deepPurpleAccent,
              onTap: () {
                // TODO: Tahsin
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── _ActionButton ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
            height: 1.3,
          ),
        ),
      ),
    );
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
