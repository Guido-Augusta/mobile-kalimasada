// GET http://10.0.2.2:5000/api/hafalan/:santriId/surah/:surahId?mode=tambah

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
    required this.juz,
    required this.checked,
  });

  final int? id;
  final int? nomorAyat;
  final String? arab;
  final String? latin;
  final String? terjemah;
  final int? juz;
  final bool? checked;

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      id: json["id"],
      nomorAyat: json["nomorAyat"],
      arab: json["arab"],
      latin: json["latin"],
      terjemah: json["terjemah"],
      juz: json["juz"],
      checked: json["checked"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomorAyat": nomorAyat,
    "arab": arab,
    "latin": latin,
    "terjemah": terjemah,
    "juz": juz,
    "checked": checked,
  };

  @override
  String toString() {
    return "$id, $nomorAyat, $arab, $latin, $terjemah, $juz, $checked, ";
  }
}

class Surah {
  Surah({
    required this.id,
    required this.nama,
    required this.namaLatin,
    required this.totalAyat,
    required this.nomor,
    required this.audio,
  });

  final int? id;
  final String? nama;
  final String? namaLatin;
  final int? totalAyat;
  final int? nomor;
  final String? audio;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json["id"],
      nama: json["nama"],
      namaLatin: json["namaLatin"],
      totalAyat: json["totalAyat"],
      nomor: json["nomor"],
      audio: json["audio"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "namaLatin": namaLatin,
    "totalAyat": totalAyat,
    "nomor": nomor,
    "audio": audio,
  };

  @override
  String toString() {
    return "$id, $nama, $namaLatin, $totalAyat, $nomor, $audio, ";
  }
}
