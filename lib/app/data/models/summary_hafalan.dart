class SummaryHafalan {
  SummaryHafalan({required this.pagination, required this.data});

  final Pagination? pagination;
  final List<Datum> data;

  factory SummaryHafalan.fromJson(Map<String, dynamic> json) {
    return SummaryHafalan(
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$pagination, $data, ";
  }
}

class Datum {
  Datum({
    required this.id,
    required this.nama,
    required this.noInduk,
    required this.tahapHafalan,
    required this.terakhirHafalan,
  });

  final int? id;
  final String? nama;
  final dynamic noInduk;
  final String? tahapHafalan;
  final TerakhirHafalan? terakhirHafalan;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      nama: json["nama"],
      noInduk: json["noInduk"],
      tahapHafalan: json["tahapHafalan"],
      terakhirHafalan: json["terakhirHafalan"] == null
          ? null
          : TerakhirHafalan.fromJson(json["terakhirHafalan"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "noInduk": noInduk,
    "tahapHafalan": tahapHafalan,
    "terakhirHafalan": terakhirHafalan?.toJson(),
  };

  @override
  String toString() {
    return "$id, $nama, $noInduk, $tahapHafalan, $terakhirHafalan, ";
  }
}

class TerakhirHafalan {
  TerakhirHafalan({
    required this.tanggal,
    required this.status,
    required this.surah,
    required this.surahId,
    required this.ayatDetail,
  });

  final DateTime? tanggal;
  final String? status;
  final String? surah;
  final int? surahId;
  final String? ayatDetail;

  factory TerakhirHafalan.fromJson(Map<String, dynamic> json) {
    return TerakhirHafalan(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      status: json["status"],
      surah: json["surah"],
      surahId: json["surahId"],
      ayatDetail: json["ayatDetail"],
    );
  }

  Map<String, dynamic> toJson() => {
    "tanggal":
        "${tanggal?.year.toString().padLeft(4, '0')}-${tanggal?.month.toString().padLeft(2, '0')}-${tanggal?.day.toString().padLeft(2, '0')}",
    "status": status,
    "surah": surah,
    "surahId": surahId,
    "ayatDetail": ayatDetail,
  };

  @override
  String toString() {
    return "$tanggal, $status, $surah, $surahId, $ayatDetail, ";
  }
}

class Pagination {
  Pagination({
    required this.page,
    required this.limit,
    required this.totalData,
    required this.totalPages,
    required this.filter,
  });

  final int? page;
  final int? limit;
  final int? totalData;
  final int? totalPages;
  final Filter? filter;

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json["page"],
      limit: json["limit"],
      totalData: json["totalData"],
      totalPages: json["totalPages"],
      filter: json["filter"] == null ? null : Filter.fromJson(json["filter"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "totalData": totalData,
    "totalPages": totalPages,
    "filter": filter?.toJson(),
  };

  @override
  String toString() {
    return "$page, $limit, $totalData, $totalPages, $filter, ";
  }
}

class Filter {
  Filter({required this.tahapHafalan, required this.status});

  final String? tahapHafalan;
  final String? status;

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(tahapHafalan: json["tahapHafalan"], status: json["status"]);
  }

  Map<String, dynamic> toJson() => {
    "tahapHafalan": tahapHafalan,
    "status": status,
  };

  @override
  String toString() {
    return "$tahapHafalan, $status, ";
  }
}
