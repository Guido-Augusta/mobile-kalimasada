class SummaryHafalanJuz {
  SummaryHafalanJuz({
    required this.mode,
    required this.pagination,
    required this.data,
  });

  final String? mode;
  final Pagination? pagination;
  final List<Datum> data;

  factory SummaryHafalanJuz.fromJson(Map<String, dynamic> json) {
    return SummaryHafalanJuz(
      mode: json["mode"],
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "mode": mode,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$mode, $pagination, $data, ";
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
  final String? noInduk;
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
    required this.juz,
    required this.halamanDetail,
    required this.surahList,
  });

  final DateTime? tanggal;
  final String? status;
  final int? juz;
  final String? halamanDetail;
  final List<SurahList> surahList;

  factory TerakhirHafalan.fromJson(Map<String, dynamic> json) {
    return TerakhirHafalan(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      status: json["status"],
      juz: json["juz"],
      halamanDetail: json["halamanDetail"],
      surahList: json["surahList"] == null
          ? []
          : List<SurahList>.from(
              json["surahList"]!.map((x) => SurahList.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "tanggal":
        "${tanggal?.year.toString().padLeft(4, '0')}-${tanggal?.month.toString().padLeft(2, '0')}-${tanggal?.day.toString().padLeft(2, '0')}",
    "status": status,
    "juz": juz,
    "halamanDetail": halamanDetail,
    "surahList": surahList.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$tanggal, $status, $juz, $halamanDetail, $surahList, ";
  }
}

class SurahList {
  SurahList({required this.namaLatin, required this.id});

  final String? namaLatin;
  final int? id;

  factory SurahList.fromJson(Map<String, dynamic> json) {
    return SurahList(namaLatin: json["namaLatin"], id: json["id"]);
  }

  Map<String, dynamic> toJson() => {"namaLatin": namaLatin, "id": id};

  @override
  String toString() {
    return "$namaLatin, $id, ";
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
