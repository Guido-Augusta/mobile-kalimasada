class ProgresHafalan {
  ProgresHafalan({required this.santri, required this.data});

  final Santri? santri;
  final List<Datum> data;

  factory ProgresHafalan.fromJson(Map<String, dynamic> json) {
    return ProgresHafalan(
      santri: json["santri"] == null ? null : Santri.fromJson(json["santri"]),
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "santri": santri?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$santri, $data, ";
  }
}

class Datum {
  Datum({
    required this.id,
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.totalAyat,
    required this.progress,
  });

  final int? id;
  final int? nomor;
  final String? nama;
  final String? namaLatin;
  final int? totalAyat;
  final String? progress;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      nomor: json["nomor"],
      nama: json["nama"],
      namaLatin: json["namaLatin"],
      totalAyat: json["totalAyat"],
      progress: json["progress"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomor": nomor,
    "nama": nama,
    "namaLatin": namaLatin,
    "totalAyat": totalAyat,
    "progress": progress,
  };

  @override
  String toString() {
    return "$id, $nomor, $nama, $namaLatin, $totalAyat, $progress, ";
  }
}

class Santri {
  Santri({
    required this.id,
    required this.nama,
    required this.ortuId,
    required this.tahapHafalan,
    required this.tingkatan,
    required this.totalPoin,
  });

  final int? id;
  final String? nama;
  final int? ortuId;
  final String? tahapHafalan;
  final String? tingkatan;
  final int? totalPoin;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      nama: json["nama"],
      ortuId: json["ortuId"],
      tahapHafalan: json["tahapHafalan"],
      tingkatan: json["tingkatan"],
      totalPoin: json["totalPoin"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "ortuId": ortuId,
    "tahapHafalan": tahapHafalan,
    "tingkatan": tingkatan,
    "totalPoin": totalPoin,
  };

  @override
  String toString() {
    return "$id, $nama, $ortuId, $tahapHafalan, $tingkatan, $totalPoin, ";
  }
}
