import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart' as rx;
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
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        title: Text(
          'Detail Surah',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Obx(() {
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
                        onPressed: () {
                          controller.audioPlayer.play();
                        },
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        icon: const Icon(
                          Icons.pause_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.audioPlayer.pause();
                        },
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
                      icon: Icon(Icons.play_arrow_rounded, color: Colors.white),
                    );
                  },
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
          return const Center(child: CircularProgressIndicator());
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
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurpleAccent,
                        Colors.deepPurple[700]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.1),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        controller.detailSurah.value?.namaLatin ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.detailSurah.value?.arti ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.3),
                          thickness: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.detailSurah.value?.tempatTurun?.toUpperCase()} • ${controller.detailSurah.value?.jumlahAyat} AYAT',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 8),
                      // Player controls
                      Row(
                        children: [
                          // Play/Pause button
                          StreamBuilder<PlayerState>(
                            stream: controller.audioPlayer.playerStateStream,
                            builder: (context, snapshot) {
                              final playerState = snapshot.data;
                              final processingState =
                                  playerState?.processingState;
                              final playing = playerState?.playing;
                              if (!(playing ?? false)) {
                                return IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: const Icon(
                                    Icons.play_circle_filled_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.audioPlayer.play();
                                  },
                                );
                              } else if (processingState !=
                                  ProcessingState.completed) {
                                return IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  icon: const Icon(
                                    Icons.pause_circle_filled_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    controller.audioPlayer.pause();
                                  },
                                );
                              }
                              return IconButton(
                                onPressed: () {
                                  if (processingState ==
                                      ProcessingState.completed) {
                                    controller.audioPlayer.seek(Duration.zero);
                                    controller.audioPlayer.play();
                                  }
                                },
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                icon: Icon(
                                  Icons.play_circle_filled_rounded,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),

                          // Progress bar
                          Expanded(
                            child: Column(
                              children: [
                                // Progress bar
                                StreamBuilder<PositionData>(
                                  stream: positionDataStream,
                                  builder: (context, snapshot) {
                                    final positionData = snapshot.data;
                                    return ProgressBar(
                                      barHeight: 6,
                                      baseBarColor: Colors.grey,
                                      progressBarColor: Colors.white,
                                      thumbColor: Colors.white,
                                      bufferedBarColor: Colors.grey[400],
                                      timeLabelTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      progress:
                                          positionData?.position ??
                                          Duration.zero,
                                      buffered:
                                          positionData?.bufferedPosition ??
                                          Duration.zero,
                                      total:
                                          positionData?.duration ??
                                          Duration.zero,
                                      onSeek: controller.audioPlayer.seek,
                                    );
                                  },
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
                          side: BorderSide(color: Colors.grey[200]!, width: 1),
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
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      ayat.ar!,
                                      style: GoogleFonts.amiri(
                                        fontSize: 24,
                                        height: 2.5,
                                      ),
                                      textAlign: TextAlign.right,
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
                                      color: Colors.grey[700],
                                      fontStyle: FontStyle.italic,
                                      height: 1.4,
                                    ),
                                  ),
                                ),

                              // Translation
                              if (ayat?.idn != null && ayat!.idn!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
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
