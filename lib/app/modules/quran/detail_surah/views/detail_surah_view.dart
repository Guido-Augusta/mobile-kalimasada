import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mobile_kalimasada/app/widgets/custom_animation_search_bar.dart';
import 'package:mobile_kalimasada/app/utils/quran_utils.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../controllers/detail_surah_controller.dart';

class DetailSurahView extends GetView<DetailSurahController> {
  const DetailSurahView({super.key});

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
            child: Obx(
              () => CustomAnimationSearchBar(
                controller: controller.searchC,
                onSubmitted: (text) {
                  final val = int.tryParse(text);
                  if (val != null) {
                    controller.scrollToAyat(val);
                  }
                },
                centerTitle: 'Detail Surah',
                hintText:
                    'Cari ayat (1-${controller.detailSurah.value?.jumlahAyat})...',
                keyboardType: TextInputType.number,
                maxValue: controller.detailSurah.value?.jumlahAyat,
                showSearchIcon: !controller.isLoading.value,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Obx(() {
          if (controller.detailSurah.value == null) {
            return const SizedBox.shrink();
          }
          return AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: controller.isFabVisible.value
                ? Offset.zero
                : const Offset(2, 0), // geser ke kanan
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
                const SizedBox(height: 10),
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
        body: SafeArea(
          top: false,
          child: Obx(() {
            if (controller.isLoading.value) {
              return _buildSkeleton();
            }

            if (controller.detailSurah.value == null) {
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
                  SliverToBoxAdapter(child: _buildSurahHeaderCard(context)),

                  // Ayat List
                  if (controller.detailSurah.value?.ayat.isEmpty ?? true)
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
                        final ayat = controller.detailSurah.value?.ayat[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Card(
                            color: Colors.white,
                            elevation: 1,
                            shadowColor: Colors.black.withValues(alpha: 0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${ayat?.nomor}',
                                        style: TextStyle(
                                          color: Colors.deepPurpleAccent[700],
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Arabic Text
                                  if (ayat?.ar != null && ayat!.ar!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          '${ayat.ar!} ${QuranUtils.getAyahEndSymbol(ayat.nomor!)}',
                                          style: GoogleFonts.amiri(
                                            fontSize: 22,
                                            height: 2.5,
                                          ),
                                          textAlign: TextAlign.right,
                                          textDirection: TextDirection.rtl,
                                        ),
                                      ),
                                    ),

                                  // Latin Text
                                  if (ayat?.tr != null && ayat!.tr!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(
                                        ayat.tr!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontStyle: FontStyle.italic,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),

                                  // Translation
                                  if (ayat?.idn != null &&
                                      ayat!.idn!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.deepPurpleAccent
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          ayat.idn!,
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
                        );
                      }, childCount: controller.detailSurah.value?.ayat.length),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSurahHeaderCard(BuildContext context) {
    final surah = controller.detailSurah.value;
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
                            width: 38,
                            height: 38,
                            padding: const EdgeInsets.all(8),
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          );
                        }

                        IconData iconData;
                        VoidCallback? onTap;

                        if (!(playing ?? false)) {
                          iconData = Icons.play_arrow_rounded;
                          onTap = controller.audioPlayer.play;
                        } else if (processingState !=
                            ProcessingState.completed) {
                          iconData = Icons.pause_rounded;
                          onTap = controller.audioPlayer.pause;
                        } else {
                          iconData = Icons.replay_rounded;
                          onTap = () {
                            controller.audioPlayer.seek(Duration.zero);
                            controller.audioPlayer.play();
                          };
                        }

                        return GestureDetector(
                          onTap: onTap,
                          child: CircleAvatar(
                            radius: 19,
                            backgroundColor: Colors.white,
                            child: Icon(
                              iconData,
                              size: 28,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
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

  // ── Skeleton Loading ─────────────────────────────────────────────────────────

  Widget _buildSkeleton() {
    return Skeletonizer(
      enabled: true,
      child: CustomScrollView(
        slivers: [
          // ── Skeleton Header Card ────────────────────────────────────────────
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
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Bone.text(
                                  words: 2,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Bone.text(
                                  words: 2,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Bone(
                            width: 110,
                            height: 28,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.2),
                        height: 1,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Bone.circle(size: 44),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              children: [
                                Bone(
                                  height: 5,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Bone.text(
                                      words: 1,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    Bone.text(
                                      words: 1,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Skeleton Ayat Cards ──────────────────────────────────────────────
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildSkeletonAyatCard(index + 1),
              childCount: 5,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSkeletonAyatCard(int nomor) {
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
              // Nomor ayat badge
              Bone(
                width: 32,
                height: 32,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 12),

              // Arabic text placeholder
              Align(
                alignment: Alignment.centerRight,
                child: Bone.multiText(
                  lines: 2,
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
