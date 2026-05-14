class QuranUtils {
  /// Mengonversi angka latin (1, 2, 3) ke angka Arab-Indic (١, ٢, ٣)
  static String toArabicIndic(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicDigits[int.parse(d)]).join();
  }

  /// Mengambil simbol End of Ayah (\u06DD) dengan nomor ayat di dalamnya
  static String getAyahEndSymbol(int ayahNumber) {
    return '\u06DD${toArabicIndic(ayahNumber)}';
  }
}
