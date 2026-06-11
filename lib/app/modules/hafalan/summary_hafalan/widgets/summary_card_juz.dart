import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/summary_hafalan_juz.dart'
    as juz_model;

class SummaryCardJuz extends StatelessWidget {
  final juz_model.Datum item;
  final String status;

  const SummaryCardJuz({
    super.key,
    required this.item,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final terakhir = item.terakhirHafalan;
    final hasData = terakhir != null;

    final tanggal = hasData && terakhir.tanggal != null
        ? DateFormat('dd MMM yyyy', 'id_ID').format(terakhir.tanggal!)
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(item.id, item.nama, tanggal),
          Divider(height: 1, color: Colors.grey[100]),
          hasData
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.toNamed(
                        '/detail-hafalan-juz',
                        arguments: {
                          'santriId': item.id,
                          'juzId': terakhir.juz,
                          'santriName': item.nama,
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                      child: Row(
                        children: [
                          _buildInfoIcon(Icons.menu_book_rounded),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Juz ${terakhir.juz ?? '-'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if ((terakhir.halamanDetail ?? '').isNotEmpty)
                                  Text(
                                    'Hal. ${terakhir.halamanDetail}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          _buildStatusBadge(status),
                        ],
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                  child: _buildNoDataText(status),
                ),
          Divider(height: 1, color: Colors.grey[100]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    label: 'Detail Riwayat',
                    icon: Icons.history_rounded,
                    color: Colors.orange,
                    enabled: hasData,
                    onTap: hasData
                        ? () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Get.toNamed(
                              '/detail-riwayat-hafalan',
                              arguments: {
                                'santriId': item.id,
                                'juzId': terakhir.juz,
                                'tanggalRiwayat': terakhir.tanggal,
                                'status': terakhir.status,
                              },
                            );
                          }
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    label: 'Hafalan',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF10B981),
                    enabled: true,
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.toNamed(
                        '/progres-hafalan',
                        arguments: {'santriId': item.id.toString()},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(int? santriId, String? nama, String? tanggal) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.toNamed('/detail-santri', arguments: santriId.toString());
        },
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    nama ?? 'Nama Santri',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (tanggal != null) _buildDateBadge(tanggal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.person, size: 22, color: Colors.deepPurpleAccent),
    );
  }

  Widget _buildDateBadge(String tanggal) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[600]!.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tanggal,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildInfoIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 18, color: Colors.deepPurpleAccent),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _statusLabel(status),
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNoDataText(String status) {
    return Text(
      'Belum ada riwayat ${_statusLabel(status).toLowerCase()}',
      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    VoidCallback? onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 16),
      label: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled
            ? color.withValues(alpha: 0.1)
            : Colors.grey[100],
        foregroundColor: enabled ? color : Colors.grey[400],
        disabledBackgroundColor: Colors.grey[100],
        disabledForegroundColor: Colors.grey[400],
        shadowColor: Colors.transparent,
        elevation: 0,
        side: BorderSide(
          color: enabled ? color.withValues(alpha: 0.5) : Colors.grey[200]!,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        minimumSize: const Size(double.infinity, 42),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'murajaah':
        return Colors.orangeAccent[700]!;
      case 'tahsin':
        return Colors.blueAccent[700]!;
      default:
        return const Color(0xFF10B981);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'murajaah':
        return 'Murajaah';
      case 'tahsin':
        return 'Tahsin';
      default:
        return 'Hafalan';
    }
  }
}
