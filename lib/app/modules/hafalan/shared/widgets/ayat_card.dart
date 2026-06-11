import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/quran_utils.dart';

class AyatCard extends StatelessWidget {
  final int? nomorAyat;
  final int? halaman;
  final String? arab;
  final String? latin;
  final String? terjemah;
  final bool isChecked;
  final String? kualitas;
  final String? keterangan;
  final bool isTabHafalan;

  const AyatCard({
    super.key,
    this.nomorAyat,
    this.halaman,
    this.arab,
    this.latin,
    this.terjemah,
    required this.isChecked,
    this.kualitas,
    this.keterangan,
    required this.isTabHafalan,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey[200]!;
    Color kualitasBgColor = Colors.blue[50]!;
    Color kualitasTextColor = Colors.blue[700]!;

    if (kualitas != null) {
      final k = kualitas!.toLowerCase();
      if (k == 'kurang') {
        kualitasBgColor = Colors.red[50]!;
        kualitasTextColor = Colors.red[700]!;
      } else if (k == 'cukup') {
        kualitasBgColor = Colors.orange[50]!;
        kualitasTextColor = Colors.orange[700]!;
      } else if (k == 'baik') {
        kualitasBgColor = Colors.teal[50]!;
        kualitasTextColor = Colors.teal[700]!;
      } else if (k == 'sangatbaik') {
        kualitasBgColor = Colors.blue[50]!;
        kualitasTextColor = Colors.blue[700]!;
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: isChecked ? 1.5 : 1),
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
                    '${nomorAyat ?? 0}',
                    style: TextStyle(
                      color: Colors.deepPurpleAccent[700],
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (halaman != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    'Hal. $halaman',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                if (isTabHafalan &&
                    kualitas != null &&
                    kualitas!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: kualitasBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      kualitas! == 'SangatBaik' ? 'Sangat Baik' : kualitas!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: kualitasTextColor,
                      ),
                    ),
                  ),
                ],
                if (keterangan != null && keterangan!.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: keterangan!.toLowerCase() == 'lanjut'
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      keterangan!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: keterangan!.toLowerCase() == 'lanjut'
                            ? Colors.green[700]
                            : Colors.orange[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (arab != null && arab!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$arab ${QuranUtils.getAyahEndSymbol(nomorAyat ?? 0)}',
                  style: GoogleFonts.amiri(fontSize: 22, height: 2.5),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
              ),
            ],
            if (latin != null && latin!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                latin!,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ],
            if (terjemah != null && terjemah!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  terjemah!,
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
}
