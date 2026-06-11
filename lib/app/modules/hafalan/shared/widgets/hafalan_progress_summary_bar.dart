import 'package:flutter/material.dart';

class HafalanProgressSummaryBar extends StatelessWidget {
  final int totalAyat;
  final int checkedAyat;

  const HafalanProgressSummaryBar({
    super.key,
    required this.totalAyat,
    required this.checkedAyat,
  });

  @override
  Widget build(BuildContext context) {
    final progressPct = totalAyat > 0 ? checkedAyat / totalAyat : 0.0;
    final pctStr = (progressPct * 100).toStringAsFixed(0);

    Color barColor;
    if (checkedAyat == 0) {
      barColor = Colors.red[400]!;
    } else if (checkedAyat >= totalAyat) {
      barColor = const Color(0xFF10B981);
    } else {
      barColor = Colors.orange[400]!;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progres Hafalan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$checkedAyat/$totalAyat',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    TextSpan(
                      text: '  ($pctStr%)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: barColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPct,
              minHeight: 7,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ],
      ),
    );
  }
}
