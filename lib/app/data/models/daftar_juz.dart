// GET http://localhost:5000/api/alquran/juz

class DaftarJuz {
  DaftarJuz({required this.data});

  final List<Datum> data;

  factory DaftarJuz.fromJson(Map<String, dynamic> json) {
    return DaftarJuz(
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$data, ";
  }
}

class Datum {
  Datum({required this.juz, required this.mulaiDari, required this.totalAyat});

  final int? juz;
  final MulaiDari? mulaiDari;
  final int? totalAyat;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      juz: json["juz"],
      mulaiDari: json["mulai_dari"] == null
          ? null
          : MulaiDari.fromJson(json["mulai_dari"]),
      totalAyat: json["total_ayat"],
    );
  }

  Map<String, dynamic> toJson() => {
    "juz": juz,
    "mulai_dari": mulaiDari?.toJson(),
    "total_ayat": totalAyat,
  };

  @override
  String toString() {
    return "$juz, $mulaiDari, $totalAyat, ";
  }
}

class MulaiDari {
  MulaiDari({required this.surah, required this.ayat});

  final Surah? surah;
  final int? ayat;

  factory MulaiDari.fromJson(Map<String, dynamic> json) {
    return MulaiDari(
      surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
      ayat: json["ayat"],
    );
  }

  Map<String, dynamic> toJson() => {"surah": surah?.toJson(), "ayat": ayat};

  @override
  String toString() {
    return "$surah, $ayat, ";
  }
}

class Surah {
  Surah({required this.nomor, required this.nama, required this.namaLatin});

  final int? nomor;
  final String? nama;
  final String? namaLatin;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: json["nomor"],
      nama: json["nama"],
      namaLatin: json["nama_latin"],
    );
  }

  Map<String, dynamic> toJson() => {
    "nomor": nomor,
    "nama": nama,
    "nama_latin": namaLatin,
  };

  @override
  String toString() {
    return "$nomor, $nama, $namaLatin, ";
  }
}
