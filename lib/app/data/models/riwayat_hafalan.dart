class RiwayatHafalan {
  RiwayatHafalan({
    required this.santri,
    required this.pagination,
    required this.data,
  });

  final Santri? santri;
  final Pagination? pagination;
  final List<Datum> data;

  factory RiwayatHafalan.fromJson(Map<String, dynamic> json) {
    return RiwayatHafalan(
      santri: json["santri"] == null ? null : Santri.fromJson(json["santri"]),
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "santri": santri?.toJson(),
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$santri, $pagination, $data, ";
  }
}

class Datum {
  Datum({
    required this.tanggal,
    required this.status,
    required this.surahId,
    required this.namaSurah,
    required this.namaSurahLatin,
    required this.jumlahAyat,
  });

  final DateTime? tanggal;
  final String? status;
  final int? surahId;
  final String? namaSurah;
  final String? namaSurahLatin;
  final int? jumlahAyat;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      status: json["status"],
      surahId: json["surahId"],
      namaSurah: json["namaSurah"],
      namaSurahLatin: json["namaSurahLatin"],
      jumlahAyat: json["jumlahAyat"],
    );
  }

  Map<String, dynamic> toJson() => {
    "tanggal":
        "${tanggal?.year.toString().padLeft(4, '0')}-${tanggal?.month.toString().padLeft(2, '0')}-${tanggal?.day.toString().padLeft(2, '0')}",
    "status": status,
    "surahId": surahId,
    "namaSurah": namaSurah,
    "namaSurahLatin": namaSurahLatin,
    "jumlahAyat": jumlahAyat,
  };

  @override
  String toString() {
    return "$tanggal, $status, $surahId, $namaSurah, $namaSurahLatin, $jumlahAyat, ";
  }
}

class Pagination {
  Pagination({
    required this.page,
    required this.limit,
    required this.totalData,
    required this.totalPages,
  });

  final int? page;
  final int? limit;
  final int? totalData;
  final int? totalPages;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json["page"],
      limit: json["limit"],
      totalData: json["totalData"],
      totalPages: json["totalPages"],
    );
  }

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "totalData": totalData,
    "totalPages": totalPages,
  };

  @override
  String toString() {
    return "$page, $limit, $totalData, $totalPages, ";
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
