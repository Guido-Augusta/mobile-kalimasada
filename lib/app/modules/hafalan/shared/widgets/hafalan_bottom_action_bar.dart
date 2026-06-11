import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class HafalanBottomActionBar extends StatelessWidget {
  final int tabIndex;
  final bool isVisible;
  final PlayerState? playerState;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final VoidCallback? onReplay;
  final VoidCallback onAddProgress;

  const HafalanBottomActionBar({
    super.key,
    required this.tabIndex,
    required this.isVisible,
    this.playerState,
    this.onPlay,
    this.onPause,
    this.onReplay,
    required this.onAddProgress,
  });

  @override
  Widget build(BuildContext context) {
    String label;
    Color color = Colors.deepPurpleAccent;

    if (tabIndex == 0) {
      label = 'Tambah Hafalan';
    } else if (tabIndex == 1) {
      label = 'Tambah Murajaah';
    } else {
      label = 'Tambah Tahsin';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isVisible
          ? (MediaQuery.of(context).padding.bottom + 72)
          : 0,
      child: ClipRect(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Container(
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
                if (onPlay != null) ...[
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
                      child: Builder(builder: (context) {
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
                          onTap = onPlay;
                        } else if (processingState != ProcessingState.completed) {
                          iconData = Icons.pause_rounded;
                          onTap = onPause;
                        } else {
                          iconData = Icons.replay_rounded;
                          onTap = onReplay;
                        }

                        return InkWell(
                          onTap: onTap,
                          borderRadius: BorderRadius.circular(12),
                          child: Center(
                            child: Icon(iconData, color: color, size: 28),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Material(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onAddProgress,
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
          ),
        ),
      ),
    );
  }
}
