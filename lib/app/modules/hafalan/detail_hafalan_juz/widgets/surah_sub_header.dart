import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/detail_hafalan_juz.dart';

class SurahSubHeader extends StatelessWidget {
  final AyatSurah? surah;

  const SurahSubHeader({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    if (surah == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurpleAccent.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.deepPurpleAccent.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${surah?.nomor ?? 0}',
              style: TextStyle(
                color: Colors.deepPurpleAccent[700],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              surah?.namaLatin ?? '',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.deepPurpleAccent[700],
              ),
            ),
          ),
          Text(
            surah?.nama ?? '',
            style: GoogleFonts.amiri(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurpleAccent[700],
            ),
          ),
        ],
      ),
    );
  }
}
