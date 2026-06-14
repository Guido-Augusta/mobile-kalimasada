import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RiwayatFilter extends StatelessWidget {
  final String filterMode;
  final String filterStatus;
  final Function(String) onModeChanged;
  final Function(String) onStatusChanged;

  const RiwayatFilter({
    super.key,
    required this.filterMode,
    required this.filterStatus,
    required this.onModeChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _buildDropdown(
              value: filterMode,
              items: const [
                DropdownMenuItem(value: 'ayat', child: Text('Ayat')),
                DropdownMenuItem(value: 'halaman', child: Text('Halaman')),
              ],
              onChanged: (val) {
                if (val != null) onModeChanged(val);
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildDropdown(
              value: filterStatus,
              items: const [
                DropdownMenuItem(
                  value: 'TambahHafalan',
                  child: Text('Tambah Hafalan'),
                ),
                DropdownMenuItem(value: 'Murajaah', child: Text('Murajaah')),
                DropdownMenuItem(value: 'Tahsin', child: Text('Tahsin')),
              ],
              onChanged: (val) {
                if (val != null) onStatusChanged(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.white,
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.deepPurple,
            size: 20,
          ),
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
