import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/summary_hafalan_controller.dart';

class SummaryFilterBottomSheet extends GetView<SummaryHafalanController> {
  const SummaryFilterBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const SummaryFilterBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tempStatus = controller.status.value.obs;
    final tempMode = controller.mode.value.obs;
    final tempSort = controller.filterBy.value.obs;

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: Colors.deepPurpleAccent,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Status ───────────────────────────────────────────────
            _buildSheetSectionLabel('Status'),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSheetChip(
                    label: 'Hafalan',
                    value: 'tambahHafalan',
                    selected: tempStatus.value,
                    color: const Color(0xFF10B981),
                    onTap: (v) => tempStatus.value = v,
                  ),
                  _buildSheetChip(
                    label: 'Murajaah',
                    value: 'murajaah',
                    selected: tempStatus.value,
                    color: Colors.orangeAccent[700]!,
                    onTap: (v) => tempStatus.value = v,
                  ),
                  _buildSheetChip(
                    label: 'Tahsin',
                    value: 'tahsin',
                    selected: tempStatus.value,
                    color: Colors.blueAccent[700]!,
                    onTap: (v) => tempStatus.value = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Mode ─────────────────────────────────────────────────
            _buildSheetSectionLabel('Mode Tampilan'),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                children: [
                  _buildSheetChip(
                    label: 'Ayat',
                    value: 'surah',
                    selected: tempMode.value,
                    color: Colors.deepPurple,
                    onTap: (v) => tempMode.value = v,
                  ),
                  _buildSheetChip(
                    label: 'Halaman',
                    value: 'juz',
                    selected: tempMode.value,
                    color: Colors.deepPurple,
                    onTap: (v) => tempMode.value = v,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Sort — hanya muncul jika status = tambahHafalan ──────
            Obx(() {
              if (tempStatus.value != 'tambahHafalan') {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetSectionLabel('Urutan'),
                  const SizedBox(height: 8),
                  Obx(
                    () => Wrap(
                      spacing: 8,
                      children: [
                        _buildSheetChip(
                          label: 'Terbanyak',
                          value: 'desc',
                          selected: tempSort.value,
                          color: Colors.deepPurple,
                          onTap: (v) => tempSort.value = v,
                        ),
                        _buildSheetChip(
                          label: 'Tersedikit',
                          value: 'asc',
                          selected: tempSort.value,
                          color: Colors.deepPurple,
                          onTap: (v) => tempSort.value = v,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            }),

            // ── Buttons ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      tempStatus.value = 'tambahHafalan';
                      tempMode.value = 'surah';
                      tempSort.value = 'desc';
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reset',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      bool changed = false;

                      if (controller.status.value != tempStatus.value) {
                        controller.status.value = tempStatus.value;
                        changed = true;
                      }
                      if (controller.filterBy.value != tempSort.value) {
                        controller.filterBy.value = tempSort.value;
                        changed = true;
                      }
                      if (controller.mode.value != tempMode.value) {
                        controller.mode.value = tempMode.value;
                        changed = true;
                      }
                      if (tempStatus.value != 'tambahHafalan') {
                        controller.filterBy.value = 'desc';
                      }

                      if (changed) {
                        controller.clearList();
                        controller.getSummaryHafalan();
                      }
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Terapkan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey[500],
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSheetChip({
    required String label,
    required String value,
    required String selected,
    required Color color,
    required void Function(String) onTap,
  }) {
    final isActive = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : Colors.grey[200]!,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? color : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}
