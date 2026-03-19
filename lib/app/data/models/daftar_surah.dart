// GET http://localhost:5000/api/alquran

class DaftarSurah {
  DaftarSurah({required this.data});

  final List<Datum> data;

  factory DaftarSurah.fromJson(Map<String, dynamic> json) {
    return DaftarSurah(
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
  Datum({
    required this.id,
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.totalAyat,
    required this.tempatTurun,
    required this.arti,
    required this.deskripsi,
    required this.audio,
  });

  final int? id;
  final int? nomor;
  final String? nama;
  final String? namaLatin;
  final int? totalAyat;
  final String? tempatTurun;
  final String? arti;
  final String? deskripsi;
  final String? audio;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      nomor: json["nomor"],
      nama: json["nama"],
      namaLatin: json["namaLatin"],
      totalAyat: json["totalAyat"],
      tempatTurun: json["tempatTurun"],
      arti: json["arti"],
      deskripsi: json["deskripsi"],
      audio: json["audio"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomor": nomor,
    "nama": nama,
    "namaLatin": namaLatin,
    "totalAyat": totalAyat,
    "tempatTurun": tempatTurun,
    "arti": arti,
    "deskripsi": deskripsi,
    "audio": audio,
  };

  @override
  String toString() {
    return "$id, $nomor, $nama, $namaLatin, $totalAyat, $tempatTurun, $arti, $deskripsi, $audio, ";
  }
}
