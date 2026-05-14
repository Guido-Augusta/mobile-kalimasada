class Santri {
  Santri({
    required this.id,
    required this.userId,
    required this.nama,
    required this.tahapHafalan,
    required this.peringkat,
    required this.totalPoin,
    required this.createdAt,
    required this.poinUpdatedAt,
    required this.user,
    required this.orangTua,
    required this.waliKelas,
  });

  final int? id;
  final int? userId;
  final String? nama;
  final String? tahapHafalan;
  final int? peringkat;
  final int? totalPoin;
  final DateTime? createdAt;
  final DateTime? poinUpdatedAt;
  final User? user;
  final List<OrangTua> orangTua;
  final List<WaliKelas> waliKelas;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      userId: json["userId"],
      nama: json["nama"],
      tahapHafalan: json["tahapHafalan"],
      peringkat: json["peringkat"],
      totalPoin: json["totalPoin"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      poinUpdatedAt: DateTime.tryParse(json["poinUpdatedAt"] ?? ""),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      orangTua: json["orangTua"] == null
          ? []
          : List<OrangTua>.from(
              json["orangTua"]!.map((x) => OrangTua.fromJson(x)),
            ),
      waliKelas: json["waliKelas"] == null
          ? []
          : List<WaliKelas>.from(
              json["waliKelas"]!.map((x) => WaliKelas.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "nama": nama,
    "tahapHafalan": tahapHafalan,
    "peringkat": peringkat,
    "totalPoin": totalPoin,
    "createdAt": createdAt?.toIso8601String(),
    "poinUpdatedAt": poinUpdatedAt?.toIso8601String(),
    "user": user?.toJson(),
    "orangTua": orangTua.map((x) => x.toJson()).toList(),
    "waliKelas": waliKelas.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $userId, $nama, $tahapHafalan, $peringkat, $totalPoin, $createdAt, $poinUpdatedAt, $user, $orangTua, $waliKelas, ";
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
  User({
    required this.id,
    required this.email,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final dynamic email;
  final String? password;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      email: json["email"],
      password: json["password"],
      role: json["role"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "password": password,
    "role": role,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };

  @override
  String toString() {
    return "$id, $email, $password, $role, $createdAt, $updatedAt, ";
  }
}

class WaliKelas {
  WaliKelas({
    required this.id,
    required this.nama,
    required this.nomorHp,
    required this.waliKelasTahap,
  });

  final int? id;
  final String? nama;
  final String? nomorHp;
  final String? waliKelasTahap;

  factory WaliKelas.fromJson(Map<String, dynamic> json) {
    return WaliKelas(
      id: json["id"],
      nama: json["nama"],
      nomorHp: json["nomorHp"],
      waliKelasTahap: json["waliKelasTahap"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "nomorHp": nomorHp,
    "waliKelasTahap": waliKelasTahap,
  };

  @override
  String toString() {
    return "$id, $nama, $nomorHp, $waliKelasTahap, ";
  }
}
