class RiwayatHafalanHalaman {
  RiwayatHafalanHalaman({
    required this.santri,
    required this.mode,
    required this.pagination,
    required this.data,
  });

  final Santri? santri;
  final String? mode;
  final Pagination? pagination;
  final List<Datum> data;

  factory RiwayatHafalanHalaman.fromJson(Map<String, dynamic> json) {
    return RiwayatHafalanHalaman(
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
    required this.juz,
    required this.jumlahAyat,
    required this.totalPoin,
    required this.totalHalaman,
    required this.rangeHalaman,
    required this.surah,
  });

  final DateTime? tanggal;
  final String? status;
  final int? juz;
  final int? jumlahAyat;
  final int? totalPoin;
  final int? totalHalaman;
  final RangeHalaman? rangeHalaman;
  final List<Surah> surah;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      status: json["status"],
      juz: json["juz"],
      jumlahAyat: json["jumlahAyat"],
      totalPoin: json["totalPoin"],
      totalHalaman: json["totalHalaman"],
      rangeHalaman: json["rangeHalaman"] == null
          ? null
          : RangeHalaman.fromJson(json["rangeHalaman"]),
      surah: json["surah"] == null
          ? []
          : List<Surah>.from(json["surah"]!.map((x) => Surah.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "tanggal":
        "${tanggal?.year.toString().padLeft(4, '0')}-${tanggal?.month.toString().padLeft(2, '0')}-${tanggal?.day.toString().padLeft(2, '0')}",
    "status": status,
    "juz": juz,
    "jumlahAyat": jumlahAyat,
    "totalPoin": totalPoin,
    "totalHalaman": totalHalaman,
    "rangeHalaman": rangeHalaman?.toJson(),
    "surah": surah.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$tanggal, $status, $juz, $jumlahAyat, $totalPoin, $totalHalaman, $rangeHalaman, $surah, ";
  }
}

class RangeHalaman {
  RangeHalaman({required this.awal, required this.akhir});

  final int? awal;
  final int? akhir;

  factory RangeHalaman.fromJson(Map<String, dynamic> json) {
    return RangeHalaman(awal: json["awal"], akhir: json["akhir"]);
  }

  Map<String, dynamic> toJson() => {"awal": awal, "akhir": akhir};

  @override
  String toString() {
    return "$awal, $akhir, ";
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
    required this.orangTua,
  });

  final int? id;
  final String? nama;
  final String? tahapHafalan;
  final int? totalPoin;
  final List<OrangTua> orangTua;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      nama: json["nama"],
      tahapHafalan: json["tahapHafalan"],
      totalPoin: json["totalPoin"],
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
    "orangTua": orangTua.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $nama, $tahapHafalan, $totalPoin, $orangTua, ";
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
