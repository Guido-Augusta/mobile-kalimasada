class DetailHafalanJuz {
  DetailHafalanJuz({
    required this.juz,
    required this.santriId,
    required this.mode,
    required this.totalSurah,
    required this.surah,
  });

  final int? juz;
  final int? santriId;
  final String? mode;
  final int? totalSurah;
  final List<SurahElement> surah;

  factory DetailHafalanJuz.fromJson(Map<String, dynamic> json) {
    return DetailHafalanJuz(
      juz: json["juz"],
      santriId: json["santriId"],
      mode: json["mode"],
      totalSurah: json["totalSurah"],
      surah: json["surah"] == null
          ? []
          : List<SurahElement>.from(
              json["surah"]!.map((x) => SurahElement.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "juz": juz,
    "santriId": santriId,
    "mode": mode,
    "totalSurah": totalSurah,
    "surah": surah.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$juz, $santriId, $mode, $totalSurah, $surah, ";
  }
}

class SurahElement {
  SurahElement({required this.surah, required this.ayat});

  final AyatSurah? surah;
  final List<Ayat> ayat;

  factory SurahElement.fromJson(Map<String, dynamic> json) {
    return SurahElement(
      surah: json["surah"] == null ? null : AyatSurah.fromJson(json["surah"]),
      ayat: json["ayat"] == null
          ? []
          : List<Ayat>.from(json["ayat"]!.map((x) => Ayat.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "surah": surah?.toJson(),
    "ayat": ayat.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$surah, $ayat, ";
  }
}

class Ayat {
  Ayat({
    required this.id,
    required this.nomorAyat,
    required this.arab,
    required this.latin,
    required this.terjemah,
    required this.halaman,
    required this.surah,
    required this.checked,
    required this.kualitas,
    required this.keterangan,
  });

  final int? id;
  final int? nomorAyat;
  final String? arab;
  final String? latin;
  final String? terjemah;
  final int? halaman;
  final AyatSurah? surah;
  final bool? checked;
  final String? kualitas;
  final String? keterangan;

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      id: json["id"],
      nomorAyat: json["nomorAyat"],
      arab: json["arab"],
      latin: json["latin"],
      terjemah: json["terjemah"],
      halaman: json["halaman"],
      surah: json["surah"] == null ? null : AyatSurah.fromJson(json["surah"]),
      checked: json["checked"],
      kualitas: json["kualitas"],
      keterangan: json["keterangan"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomorAyat": nomorAyat,
    "arab": arab,
    "latin": latin,
    "terjemah": terjemah,
    "halaman": halaman,
    "surah": surah?.toJson(),
    "checked": checked,
    "kualitas": kualitas,
    "keterangan": keterangan,
  };

  @override
  String toString() {
    return "$id, $nomorAyat, $arab, $latin, $terjemah, $halaman, $surah, $checked, $kualitas, $keterangan, ";
  }
}

class AyatSurah {
  AyatSurah({
    required this.id,
    required this.nomor,
    required this.nama,
    required this.namaLatin,
  });

  final int? id;
  final int? nomor;
  final String? nama;
  final String? namaLatin;

  factory AyatSurah.fromJson(Map<String, dynamic> json) {
    return AyatSurah(
      id: json["id"],
      nomor: json["nomor"],
      nama: json["nama"],
      namaLatin: json["namaLatin"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomor": nomor,
    "nama": nama,
    "namaLatin": namaLatin,
  };

  @override
  String toString() {
    return "$id, $nomor, $nama, $namaLatin, ";
  }
}
