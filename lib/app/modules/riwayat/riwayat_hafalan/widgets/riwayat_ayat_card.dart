import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mobile_kalimasada/app/data/models/riwayat_hafalan_ayat.dart' as model_ayat;
import 'package:mobile_kalimasada/app/services/auth_service.dart';

class RiwayatAyatCard extends StatelessWidget {
  final model_ayat.Datum datum;
  final model_ayat.Santri santri;
  final String filterStatus;
  final String Function(String?) getStatusText;
  final Function(model_ayat.Datum datum, model_ayat.Santri santri, String subtitle) onDelete;

  const RiwayatAyatCard({
    super.key,
    required this.datum,
    required this.santri,
    required this.filterStatus,
    required this.getStatusText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String title = datum.namaSurahLatin ?? '-';
    final String subtitle = datum.namaSurahLatin ?? '';
    final String rangeLabel = 'Ayat ${datum.rangeAyat?.awal ?? 0} - ${datum.rangeAyat?.akhir ?? 0}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            final args = {
              'santriId': santri.id,
              'tanggalRiwayat': datum.tanggal,
              'status': datum.status,
              'surahId': datum.surahId,
            };
            Get.toNamed('/detail-riwayat-hafalan', arguments: args);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_stories_rounded,
                        color: Colors.deepPurpleAccent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              rangeLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(datum.status).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(datum.status).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        getStatusText(datum.status),
                        style: GoogleFonts.poppins(
                          color: _getStatusColor(datum.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: Colors.grey[200]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge(
                            Icons.calendar_month_rounded,
                            datum.tanggal != null
                                ? DateFormat('dd MMM yyyy', 'id_ID').format(datum.tanggal!)
                                : '-',
                          ),
                          if (filterStatus == 'TambahHafalan')
                            _buildBadge(
                              Icons.auto_awesome_rounded,
                              '${datum.totalPoin ?? 0} poin',
                              color: Colors.amber[600],
                            ),
                        ],
                      ),
                    ),
                    if (AuthService.to.isUstadz)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () => onDelete(datum, santri, subtitle),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.delete_outline_rounded,
                              size: 20,
                              color: Colors.red[400],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey[600]!).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'murajaah':
        return Colors.orangeAccent[700]!;
      case 'tambahhafalan':
        return const Color(0xFF10B981);
      case 'tahsin':
        return Colors.blueAccent[700]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
