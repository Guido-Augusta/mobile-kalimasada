class DaftarUstadz {
  DaftarUstadz({required this.pagination, required this.data});

  final Pagination? pagination;
  final List<Datum> data;

  factory DaftarUstadz.fromJson(Map<String, dynamic> json) {
    return DaftarUstadz(
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
    required this.userId,
    required this.nama,
    required this.nomorHp,
    required this.alamat,
    required this.jenisKelamin,
    required this.fotoProfil,
    required this.waliKelasTahap,
    required this.user,
  });

  final int? id;
  final int? userId;
  final String? nama;
  final String? nomorHp;
  final String? alamat;
  final String? jenisKelamin;
  final String? fotoProfil;
  final String? waliKelasTahap;
  final User? user;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      userId: json["userId"],
      nama: json["nama"],
      nomorHp: json["nomorHp"],
      alamat: json["alamat"],
      jenisKelamin: json["jenisKelamin"],
      fotoProfil: json["fotoProfil"],
      waliKelasTahap: json["waliKelasTahap"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "nama": nama,
    "nomorHp": nomorHp,
    "alamat": alamat,
    "jenisKelamin": jenisKelamin,
    "fotoProfil": fotoProfil,
    "waliKelasTahap": waliKelasTahap,
    "user": user?.toJson(),
  };

  @override
  String toString() {
    return "$id, $userId, $nama, $nomorHp, $alamat, $jenisKelamin, $fotoProfil, $waliKelasTahap, $user, ";
  }
}

class User {
  User({required this.id, required this.email, required this.role});

  final int? id;
  final String? email;
  final String? role;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json["id"], email: json["email"], role: json["role"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "email": email, "role": role};

  @override
  String toString() {
    return "$id, $email, $role, ";
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
