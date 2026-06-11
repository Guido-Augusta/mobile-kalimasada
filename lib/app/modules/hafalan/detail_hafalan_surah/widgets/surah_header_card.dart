import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import '../controllers/detail_hafalan_surah_controller.dart';

class SurahHeaderCard extends StatelessWidget {
  final DetailHafalanSurahController controller;

  const SurahHeaderCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
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
                  Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Obx(() {
                        final pState = controller.playerState.value;
                        final processingState = pState?.processingState;
                        final playing = pState?.playing;

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
                          onTap = controller.playAudio;
                        } else if (processingState != ProcessingState.completed) {
                          iconData = Icons.pause_rounded;
                          onTap = controller.pauseAudio;
                        } else {
                          iconData = Icons.replay_rounded;
                          onTap = controller.replayAudio;
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
                      }),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Obx(() {
                          final posData = controller.positionData.value;
                          return ProgressBar(
                            barHeight: 5,
                            baseBarColor: Colors.white.withValues(alpha: 0.3),
                            progressBarColor: Colors.white,
                            thumbColor: Colors.white,
                            bufferedBarColor:
                                Colors.white.withValues(alpha: 0.5),
                            timeLabelTextStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                            progress: posData.position,
                            buffered: posData.bufferedPosition,
                            total: posData.duration,
                            onSeek: controller.seekAudio,
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
