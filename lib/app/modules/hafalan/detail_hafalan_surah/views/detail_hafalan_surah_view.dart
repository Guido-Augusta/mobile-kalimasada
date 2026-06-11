import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/widgets/custom_animation_search_bar.dart';
import '../controllers/detail_hafalan_surah_controller.dart';
import '../widgets/surah_header_card.dart';
import '../widgets/add_progress_bottom_sheet.dart';
import '../../shared/widgets/hafalan_tab_bar.dart';
import '../../shared/widgets/hafalan_progress_summary_bar.dart';
import '../../shared/widgets/ayat_card.dart';
import '../../shared/widgets/hafalan_bottom_action_bar.dart';

class DetailHafalanSurahView extends GetView<DetailHafalanSurahController> {
  const DetailHafalanSurahView({super.key});

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
              showSearchIcon:
                  !controller.isSurahInfoLoading.value &&
                  controller.surahInfo.value != null,
            ),
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (!AuthService.to.isUstadz) return const SizedBox.shrink();
        if (controller.isSurahInfoLoading.value ||
            controller.isCurrentLoading) {
          return const SizedBox.shrink();
        }
        if (controller.currentDetail == null &&
            controller.surahInfo.value == null) {
          return const SizedBox.shrink();
        }

        return HafalanBottomActionBar(
          tabIndex: controller.selectedTab.value,
          isVisible: controller.isActionBarVisible.value,
          playerState: controller.playerState.value,
          onPlay: controller.playAudio,
          onPause: controller.pauseAudio,
          onReplay: controller.replayAudio,
          onAddProgress: () => _showAddProgressBottomSheet(
            context,
            controller.selectedTab.value,
          ),
        );
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
                Obx(() {
                  final pState = controller.playerState.value;
                  final processingState = pState?.processingState;
                  final playing = pState?.playing;

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
                      onPressed: controller.playAudio,
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
                      onPressed: controller.pauseAudio,
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
                      onPressed: controller.replayAudio,
                      child: const Icon(
                        Icons.replay_rounded,
                        color: Colors.white,
                      ),
                    );
                  }
                }),
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

        if (controller.currentDetail == null &&
            controller.surahInfo.value == null) {
          return RefreshIndicator(
            onRefresh: () async => controller.getSurahInfo(),
            color: Colors.deepPurpleAccent,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    kToolbarHeight -
                    MediaQuery.of(context).padding.top,
                width: MediaQuery.of(context).size.width,
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
              ),
            ),
          );
        }

        return SafeArea(
          top: false,
          child: NotificationListener<UserScrollNotification>(
            onNotification: (notification) {
              if (notification.direction == ScrollDirection.reverse) {
                controller.isFabVisible.value = false;
                controller.isActionBarVisible.value = false;
              } else if (notification.direction == ScrollDirection.forward) {
                controller.isFabVisible.value = true;
                controller.isActionBarVisible.value = true;
              }
              return true;
            },
            child: CustomScrollView(
              controller: controller.scrollC,
              slivers: [
                SliverToBoxAdapter(
                  child: SurahHeaderCard(controller: controller),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: StickyTabBarDelegate(
                    child: HafalanTabBar(
                      selectedTab: controller.selectedTab.value,
                      onTabChanged: controller.changeTab,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Skeletonizer(
                    enabled: controller.isCurrentLoading,
                    child: Builder(
                      builder: (context) {
                        final ayatList = controller.currentDetail?.ayat ?? [];
                        final totalAyat = ayatList.length;
                        final checkedAyat = ayatList
                            .where(
                              (a) =>
                                  a.checked == true &&
                                  a.keterangan?.toLowerCase() == 'lanjut',
                            )
                            .length;
                        return HafalanProgressSummaryBar(
                          totalAyat: totalAyat,
                          checkedAyat: checkedAyat,
                        );
                      },
                    ),
                  ),
                ),
                if (controller.isCurrentLoading &&
                    (controller.currentDetail?.ayat.isEmpty ?? true))
                  SliverSkeletonizer(
                    enabled: true,
                    child: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return AyatCard(
                          nomorAyat: index + 1,
                          arab: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                          latin: 'Bismillaahir Rahmaanir Raheem',
                          terjemah:
                              'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang.',
                          isChecked: false,
                          kualitas: 'Baik',
                          keterangan: 'Lanjut',
                          isTabHafalan: controller.selectedTab.value == 0,
                        );
                      }, childCount: 5),
                    ),
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
                  SliverSkeletonizer(
                    enabled: controller.isCurrentLoading,
                    child: SuperSliverList(
                      listController: controller.listC,
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final ayat = controller.currentDetail?.ayat[index];
                          return AyatCard(
                            nomorAyat: ayat?.nomorAyat,
                            arab: ayat?.arab,
                            latin: ayat?.latin,
                            terjemah: ayat?.terjemah,
                            isChecked: ayat?.checked ?? false,
                            kualitas: ayat?.kualitas,
                            keterangan: ayat?.keterangan,
                            isTabHafalan: controller.selectedTab.value == 0,
                          );
                        },
                        childCount: controller.currentDetail?.ayat.length ?? 0,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showAddProgressBottomSheet(BuildContext context, int modeIndex) {
    controller.isFabVisible.value = false;
    showModalBottomSheet(
      context: context,
      builder: (_) => AddProgressBottomSheet(
        modeIndex: modeIndex,
        totalAyat: controller.surahInfo.value?.jumlahAyat ?? 0,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
