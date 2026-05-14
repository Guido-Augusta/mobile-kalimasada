class DaftarSantri {
  DaftarSantri({
    required this.pagination,
    required this.data,
    required this.totalSantri,
  });

  final Pagination? pagination;
  final List<Datum> data;
  final int? totalSantri;

  factory DaftarSantri.fromJson(Map<String, dynamic> json) {
    return DaftarSantri(
      pagination: json["pagination"] == null
          ? null
          : Pagination.fromJson(json["pagination"]),
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      totalSantri: json["totalSantri"],
    );
  }

  Map<String, dynamic> toJson() => {
    "pagination": pagination?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
    "totalSantri": totalSantri,
  };

  @override
  String toString() {
    return "$pagination, $data, $totalSantri, ";
  }
}

class Datum {
  Datum({
    required this.id,
    required this.userId,
    required this.nama,
    required this.tahapHafalan,
    required this.totalPoin,
    required this.peringkat,
    required this.createdAt,
    required this.poinUpdatedAt,
    required this.user,
    required this.orangTua,
  });

  final int? id;
  final int? userId;
  final String? nama;
  final String? tahapHafalan;
  final int? totalPoin;
  final int? peringkat;
  final DateTime? createdAt;
  final DateTime? poinUpdatedAt;
  final User? user;
  final List<OrangTua> orangTua;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      userId: json["userId"],
      nama: json["nama"],
      tahapHafalan: json["tahapHafalan"],
      totalPoin: json["totalPoin"],
      peringkat: json["peringkat"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      poinUpdatedAt: DateTime.tryParse(json["poinUpdatedAt"] ?? ""),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      orangTua: json["orangTua"] == null
          ? []
          : List<OrangTua>.from(
              json["orangTua"]!.map((x) => OrangTua.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "nama": nama,
    "tahapHafalan": tahapHafalan,
    "totalPoin": totalPoin,
    "peringkat": peringkat,
    "createdAt": createdAt?.toIso8601String(),
    "poinUpdatedAt": poinUpdatedAt?.toIso8601String(),
    "user": user?.toJson(),
    "orangTua": orangTua.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $userId, $nama, $tahapHafalan, $totalPoin, $peringkat, $createdAt, $poinUpdatedAt, $user, $orangTua, ";
  }
}

class OrangTua {
  OrangTua({required this.id, required this.nama, required this.tipe});

  final int? id;
  final String? nama;
  final String? tipe;

  factory OrangTua.fromJson(Map<String, dynamic> json) {
    return OrangTua(id: json["id"], nama: json["nama"], tipe: json["tipe"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "nama": nama, "tipe": tipe};

  @override
  String toString() {
    return "$id, $nama, $tipe, ";
  }
}

class User {
  User({required this.id, required this.role});

  final int? id;
  final String? role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json["id"], role: json["role"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "role": role};

  @override
  String toString() {
    return "$id, $role, ";
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
