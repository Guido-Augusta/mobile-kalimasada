class DetailRiwayatHafalan {
  DetailRiwayatHafalan({required this.data});

  final Data? data;

  factory DetailRiwayatHafalan.fromJson(Map<String, dynamic> json) {
    return DetailRiwayatHafalan(
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
    required this.tanggal,
    required this.status,
    required this.ustadz,
    required this.catatan,
    required this.surah,
    required this.daftarAyat,
  });

  final DateTime? tanggal;
  final String? status;
  final Ustadz? ustadz;
  final String? catatan;
  final Surah? surah;
  final List<DaftarAyat> daftarAyat;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      status: json["status"],
      ustadz: json["ustadz"] == null ? null : Ustadz.fromJson(json["ustadz"]),
      catatan: json["catatan"],
      surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
      daftarAyat: json["daftarAyat"] == null
          ? []
          : List<DaftarAyat>.from(
              json["daftarAyat"]!.map((x) => DaftarAyat.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "tanggal":
        "${tanggal?.year.toString().padLeft(4, '0')}-${tanggal?.month.toString().padLeft(2, '0')}-${tanggal?.day.toString().padLeft(2, '0')}",
    "status": status,
    "ustadz": ustadz?.toJson(),
    "catatan": catatan,
    "surah": surah?.toJson(),
    "daftarAyat": daftarAyat.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$tanggal, $status, $ustadz, $catatan, $surah, $daftarAyat, ";
  }
}

class DaftarAyat {
  DaftarAyat({
    required this.id,
    required this.nomorAyat,
    required this.arab,
    required this.latin,
    required this.terjemah,
    required this.juz,
    required this.surah,
  });

  final int? id;
  final int? nomorAyat;
  final String? arab;
  final String? latin;
  final String? terjemah;
  final int? juz;
  final Surah? surah;

  factory DaftarAyat.fromJson(Map<String, dynamic> json) {
    return DaftarAyat(
      id: json["id"],
      nomorAyat: json["nomorAyat"],
      arab: json["arab"],
      latin: json["latin"],
      terjemah: json["terjemah"],
      juz: json["juz"],
      surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomorAyat": nomorAyat,
    "arab": arab,
    "latin": latin,
    "terjemah": terjemah,
    "juz": juz,
    "surah": surah?.toJson(),
  };

  @override
  String toString() {
    return "$id, $nomorAyat, $arab, $latin, $terjemah, $juz, $surah, ";
  }
}

class Surah {
  Surah({required this.id, required this.nama, required this.namaLatin});

  final int? id;
  final String? nama;
  final String? namaLatin;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json["id"],
      nama: json["nama"],
      namaLatin: json["namaLatin"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "namaLatin": namaLatin,
  };

  @override
  String toString() {
    return "$id, $nama, $namaLatin, ";
  }
}

class Ustadz {
  Ustadz({required this.id, required this.nama});

  final int? id;
  final String? nama;

  factory Ustadz.fromJson(Map<String, dynamic> json) {
    return Ustadz(id: json["id"], nama: json["nama"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "nama": nama};

  @override
  String toString() {
    return "$id, $nama, ";
  }
}
