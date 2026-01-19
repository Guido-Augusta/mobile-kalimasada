import '../data/models/santri.dart';

extension OrangTuaListExtension on List<OrangTua> {
  bool get hasAyah => any((e) => e.tipe?.toLowerCase() == 'ayah');
  bool get hasIbu => any((e) => e.tipe?.toLowerCase() == 'ibu');
  bool get hasWali => any((e) => e.tipe?.toLowerCase() == 'wali');
  bool get hasOrangTua => hasAyah || hasIbu;

  String get sectionTitle {
    if (hasOrangTua && hasWali) return 'Informasi Orang Tua/Wali';
    if (hasOrangTua) return 'Informasi Orang Tua';
    if (hasWali) return 'Informasi Wali';
    return 'Informasi Kontak';
  }
}
