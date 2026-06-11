import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import 'package:mobile_kalimasada/app/data/models/detail_hafalan_juz.dart';
import 'package:mobile_kalimasada/app/services/auth_service.dart';
import 'package:mobile_kalimasada/app/widgets/custom_animation_search_bar.dart';

import '../controllers/detail_hafalan_juz_controller.dart';
import '../widgets/juz_header_card.dart';
import '../widgets/surah_sub_header.dart';
import '../widgets/add_progress_bottom_sheet.dart';
import '../../shared/widgets/hafalan_tab_bar.dart';
import '../../shared/widgets/hafalan_progress_summary_bar.dart';
import '../../shared/widgets/ayat_card.dart';
import '../../shared/widgets/hafalan_bottom_action_bar.dart';

class DetailHafalanJuzView extends GetView<DetailHafalanJuzController> {
  const DetailHafalanJuzView({super.key});

  static DetailHafalanJuzController? _cached;

  @override
  DetailHafalanJuzController get controller {
    if (Get.isRegistered<DetailHafalanJuzController>()) {
      _cached = Get.find<DetailHafalanJuzController>();
      return _cached!;
    }
    return _cached!;
  }

  int _getTotalItemsCount() => controller.currentItems.length;

  Widget _buildItemByIndex(int index) {
    if (index >= controller.currentItems.length) return const SizedBox.shrink();
    final item = controller.currentItems[index];

    if (item is SurahElement) {
      return SurahSubHeader(surah: item.surah);
    } else if (item is Ayat) {
      return AyatCard(
        nomorAyat: item.nomorAyat,
        halaman: item.halaman,
        arab: item.arab,
        latin: item.latin,
        terjemah: item.terjemah,
        isChecked: item.checked ?? false,
        kualitas: item.kualitas,
        keterangan: item.keterangan,
        isTabHafalan: controller.selectedTab.value == 0,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: SafeArea(
          child: Obx(() {
            return CustomAnimationSearchBar(
              controller: controller.searchC,
              onSubmitted: (text) {
                final val = int.tryParse(text);
                if (val != null) {
                  controller.scrollToHalaman(val);
                }
              },
              centerTitle: 'Detail Hafalan',
              hintText:
                  'Cari halaman (${controller.firstHalaman}-${controller.lastHalaman})...',
              keyboardType: TextInputType.number,
              minValue: controller.firstHalaman,
              maxValue: controller.lastHalaman,
              minValueErrorMessage:
                  'Halaman tidak ada di juz ini (${controller.firstHalaman}-${controller.lastHalaman})',
              maxValueErrorMessage:
                  'Halaman tidak ada di juz ini (${controller.firstHalaman}-${controller.lastHalaman})',
              showSearchIcon:
                  !controller.isJuzInfoLoading.value &&
                  controller.currentDetail != null,
            );
          }),
        ),
      ),
      bottomNavigationBar: Obx(() {
        if (!AuthService.to.isUstadz) return const SizedBox.shrink();
        if (controller.isJuzInfoLoading.value || controller.isCurrentLoading) {
          return const SizedBox.shrink();
        }
        if (controller.currentDetail == null) return const SizedBox.shrink();

        return HafalanBottomActionBar(
          tabIndex: controller.selectedTab.value,
          isVisible: controller.isActionBarVisible.value,
          onAddProgress: () => _showAddProgressBottomSheet(
            context,
            controller.selectedTab.value,
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Obx(() {
        if (controller.isJuzInfoLoading.value || controller.isCurrentLoading) {
          return const SizedBox.shrink();
        }
        if (controller.currentDetail == null) return const SizedBox.shrink();

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
                heroTag: 'down',
                backgroundColor: Colors.deepPurpleAccent,
                mini: true,
                onPressed: () {
                  final itemsLength = controller.currentItems.length;
                  if (itemsLength > 0 && controller.listC.isAttached) {
                    final targetIndex = controller.currentLastChecked;
                    if (targetIndex >= 0 && targetIndex < itemsLength) {
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
        if (controller.isJuzInfoLoading.value) {
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

        if (controller.currentDetail == null && !controller.isCurrentLoading) {
          return RefreshIndicator(
            onRefresh: () async => controller.getDetailTambah(),
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
                  child: Skeletonizer(
                    enabled: controller.isLoadingTambah.value,
                    effect: ShimmerEffect(
                      baseColor: Colors.white.withValues(alpha: 0.2),
                      highlightColor: Colors.white.withValues(alpha: 0.4),
                    ),
                    child: JuzHeaderCard(controller: controller),
                  ),
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
                        final detail = controller.currentDetail;
                        final totalAyat = detail == null
                            ? 0
                            : controller.getAyatCount(detail.surah);
                        final checkedAyat = detail == null
                            ? 0
                            : controller.getCheckedAyatCount(detail.surah);

                        return HafalanProgressSummaryBar(
                          totalAyat: totalAyat,
                          checkedAyat: checkedAyat,
                        );
                      },
                    ),
                  ),
                ),
                if (controller.isCurrentLoading &&
                    (controller.currentDetail?.surah.isEmpty ?? true))
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Skeletonizer(
                        enabled: true,
                        child: AyatCard(
                          nomorAyat: index + 1,
                          halaman: 1,
                          arab: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                          latin: 'Bismillaahir Rahmaanir Raheem',
                          terjemah:
                              'Dengan nama Allah Yang Maha Pengasih lagi Maha Penyayang.',
                          isChecked: false,
                          kualitas: 'Baik',
                          keterangan: 'Lanjut',
                          isTabHafalan: controller.selectedTab.value == 0,
                        ),
                      );
                    }, childCount: 5),
                  )
                else if (controller.currentDetail?.surah.isEmpty ?? true)
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
                      return Skeletonizer(
                        enabled: controller.isCurrentLoading,
                        child: _buildItemByIndex(index),
                      );
                    }, childCount: _getTotalItemsCount()),
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
      builder: (_) => AddProgressBottomSheet(modeIndex: modeIndex),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }
}
