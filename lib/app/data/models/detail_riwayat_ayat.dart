class DetailRiwayatAyat {
  DetailRiwayatAyat({required this.data});

  final Data? data;

  factory DetailRiwayatAyat.fromJson(Map<String, dynamic> json) {
    return DetailRiwayatAyat(
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
    required this.kualitas,
    required this.keterangan,
    required this.catatan,
    required this.totalPoin,
    required this.rangeAyat,
    required this.surah,
    required this.daftarAyat,
  });

  final DateTime? tanggal;
  final String? status;
  final Ustadz? ustadz;
  final String? kualitas;
  final String? keterangan;
  final String? catatan;
  final int? totalPoin;
  final RangeAyat? rangeAyat;
  final Surah? surah;
  final List<DaftarAyat> daftarAyat;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      status: json["status"],
      ustadz: json["ustadz"] == null ? null : Ustadz.fromJson(json["ustadz"]),
      kualitas: json["kualitas"],
      keterangan: json["keterangan"],
      catatan: json["catatan"],
      totalPoin: json["totalPoin"],
      rangeAyat: json["rangeAyat"] == null
          ? null
          : RangeAyat.fromJson(json["rangeAyat"]),
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
    "kualitas": kualitas,
    "keterangan": keterangan,
    "catatan": catatan,
    "totalPoin": totalPoin,
    "rangeAyat": rangeAyat?.toJson(),
    "surah": surah?.toJson(),
    "daftarAyat": daftarAyat.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$tanggal, $status, $ustadz, $kualitas, $keterangan, $catatan, $totalPoin, $rangeAyat, $surah, $daftarAyat, ";
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
    required this.poinDidapat,
    required this.kualitas,
    required this.keterangan,
  });

  final int? id;
  final int? nomorAyat;
  final String? arab;
  final String? latin;
  final String? terjemah;
  final int? juz;
  final Surah? surah;
  final int? poinDidapat;
  final String? kualitas;
  final String? keterangan;

  factory DaftarAyat.fromJson(Map<String, dynamic> json) {
    return DaftarAyat(
      id: json["id"],
      nomorAyat: json["nomorAyat"],
      arab: json["arab"],
      latin: json["latin"],
      terjemah: json["terjemah"],
      juz: json["juz"],
      surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
      poinDidapat: json["poinDidapat"],
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
    "juz": juz,
    "surah": surah?.toJson(),
    "poinDidapat": poinDidapat,
    "kualitas": kualitas,
    "keterangan": keterangan,
  };

  @override
  String toString() {
    return "$id, $nomorAyat, $arab, $latin, $terjemah, $juz, $surah, $poinDidapat, $kualitas, $keterangan, ";
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

class RangeAyat {
  RangeAyat({required this.awal, required this.akhir});

  final int? awal;
  final int? akhir;

  factory RangeAyat.fromJson(Map<String, dynamic> json) {
    return RangeAyat(awal: json["awal"], akhir: json["akhir"]);
  }

  Map<String, dynamic> toJson() => {"awal": awal, "akhir": akhir};

  @override
  String toString() {
    return "$awal, $akhir, ";
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
