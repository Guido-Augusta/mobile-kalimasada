class DetailJuz {
  DetailJuz({required this.data});

  final Data? data;

  factory DetailJuz.fromJson(Map<String, dynamic> json) {
    return DetailJuz(
      data: json["data"] == null ? null : Data.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {"data": data?.toJson()};

  @override
  String toString() {
    return "$data, ";
  }
}

class Data {
  Data({
    required this.juz,
    required this.mulaiDari,
    required this.totalAyat,
    required this.halaman,
    required this.ayat,
  });

  final int? juz;
  final MulaiDari? mulaiDari;
  final int? totalAyat;
  final List<int> halaman;
  final List<Ayat> ayat;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      juz: json["juz"],
      mulaiDari: json["mulai_dari"] == null
          ? null
          : MulaiDari.fromJson(json["mulai_dari"]),
      totalAyat: json["total_ayat"],
      halaman: json["halaman"] == null
          ? []
          : List<int>.from(json["halaman"]!.map((x) => x)),
      ayat: json["ayat"] == null
          ? []
          : List<Ayat>.from(json["ayat"]!.map((x) => Ayat.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "juz": juz,
    "mulai_dari": mulaiDari?.toJson(),
    "total_ayat": totalAyat,
    "halaman": halaman.map((x) => x).toList(),
    "ayat": ayat.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$juz, $mulaiDari, $totalAyat, $halaman, $ayat, ";
  }
}

class Ayat {
  Ayat({
    required this.id,
    required this.surah,
    required this.nomorAyat,
    required this.halaman,
    required this.arab,
    required this.latin,
    required this.terjemah,
  });

  final int? id;
  final Surah? surah;
  final int? nomorAyat;
  final int? halaman;
  final String? arab;
  final String? latin;
  final String? terjemah;

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      id: json["id"],
      surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
      nomorAyat: json["nomor_ayat"],
      halaman: json["halaman"],
      arab: json["arab"],
      latin: json["latin"],
      terjemah: json["terjemah"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "surah": surah?.toJson(),
    "nomor_ayat": nomorAyat,
    "halaman": halaman,
    "arab": arab,
    "latin": latin,
    "terjemah": terjemah,
  };

  @override
  String toString() {
    return "$id, $surah, $nomorAyat, $halaman, $arab, $latin, $terjemah, ";
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
