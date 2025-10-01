class DetailHafalan {
  DetailHafalan({
    required this.surah,
    required this.santriId,
    required this.mode,
    required this.ayat,
  });

  final Surah? surah;
  final int? santriId;
  final String? mode;
  final List<Ayat> ayat;

  factory DetailHafalan.fromJson(Map<String, dynamic> json) {
    return DetailHafalan(
      surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
      santriId: json["santriId"],
      mode: json["mode"],
      ayat: json["ayat"] == null
          ? []
          : List<Ayat>.from(json["ayat"]!.map((x) => Ayat.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "surah": surah?.toJson(),
    "santriId": santriId,
    "mode": mode,
    "ayat": ayat.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$surah, $santriId, $mode, $ayat, ";
  }
}

class Ayat {
  Ayat({
    required this.id,
    required this.nomorAyat,
    required this.arab,
    required this.latin,
    required this.terjemah,
    required this.checked,
  });

  final int? id;
  final int? nomorAyat;
  final String? arab;
  final String? latin;
  final String? terjemah;
  final bool? checked;

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      id: json["id"],
      nomorAyat: json["nomorAyat"],
      arab: json["arab"],
      latin: json["latin"],
      terjemah: json["terjemah"],
      checked: json["checked"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomorAyat": nomorAyat,
    "arab": arab,
    "latin": latin,
    "terjemah": terjemah,
    "checked": checked,
  };

  @override
  String toString() {
    return "$id, $nomorAyat, $arab, $latin, $terjemah, $checked, ";
  }
}

class Surah {
  Surah({
    required this.id,
    required this.nama,
    required this.namaLatin,
    required this.totalAyat,
    required this.nomor,
  });

  final int? id;
  final String? nama;
  final String? namaLatin;
  final int? totalAyat;
  final int? nomor;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json["id"],
      nama: json["nama"],
      namaLatin: json["namaLatin"],
      totalAyat: json["totalAyat"],
      nomor: json["nomor"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "namaLatin": namaLatin,
    "totalAyat": totalAyat,
    "nomor": nomor,
  };

  @override
  String toString() {
    return "$id, $nama, $namaLatin, $totalAyat, $nomor, ";
  }
}
