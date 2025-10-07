// GET http://localhost:5000/api/alquran/$surahId

class DetailSurah {
  DetailSurah({
    required this.status,
    required this.nomor,
    required this.nama,
    required this.jumlahAyat,
    required this.namaLatin,
    required this.arti,
    required this.tempatTurun,
    required this.deskripsi,
    required this.audio,
    required this.ayat,
  });

  final bool? status;
  final int? nomor;
  final String? nama;
  final int? jumlahAyat;
  final String? namaLatin;
  final String? arti;
  final String? tempatTurun;
  final String? deskripsi;
  final String? audio;
  final List<Ayat> ayat;

  factory DetailSurah.fromJson(Map<String, dynamic> json) {
    return DetailSurah(
      status: json["status"],
      nomor: json["nomor"],
      nama: json["nama"],
      jumlahAyat: json["jumlah_ayat"],
      namaLatin: json["nama_latin"],
      arti: json["arti"],
      tempatTurun: json["tempat_turun"],
      deskripsi: json["deskripsi"],
      audio: json["audio"],
      ayat: json["ayat"] == null
          ? []
          : List<Ayat>.from(json["ayat"]!.map((x) => Ayat.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "status": status,
    "nomor": nomor,
    "nama": nama,
    "jumlah_ayat": jumlahAyat,
    "nama_latin": namaLatin,
    "arti": arti,
    "tempat_turun": tempatTurun,
    "deskripsi": deskripsi,
    "audio": audio,
    "ayat": ayat.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$status, $nomor, $nama, $jumlahAyat, $namaLatin, $arti, $tempatTurun, $deskripsi, $audio, $ayat, ";
  }
}

class Ayat {
  Ayat({
    required this.id,
    required this.surah,
    required this.nomor,
    required this.ar,
    required this.tr,
    required this.idn,
    required this.juz,
  });

  final int? id;
  final int? surah;
  final int? nomor;
  final String? ar;
  final String? tr;
  final String? idn;
  final int? juz;

  factory Ayat.fromJson(Map<String, dynamic> json) {
    return Ayat(
      id: json["id"],
      surah: json["surah"],
      nomor: json["nomor"],
      ar: json["ar"],
      tr: json["tr"],
      idn: json["idn"],
      juz: json["juz"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "surah": surah,
    "nomor": nomor,
    "ar": ar,
    "tr": tr,
    "idn": idn,
    "juz": juz,
  };

  @override
  String toString() {
    return "$id, $surah, $nomor, $ar, $tr, $idn, $juz, ";
  }
}
