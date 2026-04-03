class RiwayatHafalanAyat {
  RiwayatHafalanAyat({
    required this.santri,
    required this.mode,
    required this.pagination,
    required this.data,
  });

  final Santri? santri;
  final String? mode;
  final Pagination? pagination;
  final List<Datum> data;

  factory RiwayatHafalanAyat.fromJson(Map<String, dynamic> json) {
    return RiwayatHafalanAyat(
      santri: json["santri"] == null ? null : Santri.fromJson(json["santri"]),
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
    "santri": santri?.toJson(),
    "mode": mode,
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$santri, $mode, $pagination, $data, ";
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
    required this.totalPoin,
    required this.rangeAyat,
  });

  final DateTime? tanggal;
  final String? status;
  final int? surahId;
  final String? namaSurah;
  final String? namaSurahLatin;
  final int? jumlahAyat;
  final int? totalPoin;
  final RangeAyat? rangeAyat;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      status: json["status"],
      surahId: json["surahId"],
      namaSurah: json["namaSurah"],
      namaSurahLatin: json["namaSurahLatin"],
      jumlahAyat: json["jumlahAyat"],
      totalPoin: json["totalPoin"],
      rangeAyat: json["rangeAyat"] == null
          ? null
          : RangeAyat.fromJson(json["rangeAyat"]),
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
    "totalPoin": totalPoin,
    "rangeAyat": rangeAyat?.toJson(),
  };

  @override
  String toString() {
    return "$tanggal, $status, $surahId, $namaSurah, $namaSurahLatin, $jumlahAyat, $totalPoin, $rangeAyat, ";
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
    required this.tahapHafalan,
    required this.totalPoin,
    required this.noInduk,
    required this.orangTua,
  });

  final int? id;
  final String? nama;
  final String? tahapHafalan;
  final int? totalPoin;
  final String? noInduk;
  final List<OrangTua> orangTua;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      nama: json["nama"],
      tahapHafalan: json["tahapHafalan"],
      totalPoin: json["totalPoin"],
      noInduk: json["noInduk"],
      orangTua: json["orangTua"] == null
          ? []
          : List<OrangTua>.from(
              json["orangTua"]!.map((x) => OrangTua.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "tahapHafalan": tahapHafalan,
    "totalPoin": totalPoin,
    "noInduk": noInduk,
    "orangTua": orangTua.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $nama, $tahapHafalan, $totalPoin, $noInduk, $orangTua, ";
  }
}

class OrangTua {
  OrangTua({required this.id, required this.nama, required this.user});

  final int? id;
  final String? nama;
  final User? user;

  factory OrangTua.fromJson(Map<String, dynamic> json) {
    return OrangTua(
      id: json["id"],
      nama: json["nama"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "user": user?.toJson(),
  };

  @override
  String toString() {
    return "$id, $nama, $user, ";
  }
}

class User {
  User({required this.email});

  final String? email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json["email"]);
  }

  Map<String, dynamic> toJson() => {"email": email};

  @override
  String toString() {
    return "$email, ";
  }
}
