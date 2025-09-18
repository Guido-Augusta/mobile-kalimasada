// GET http://localhost:5000/api/santri/santriId

class Santri {
  Santri({
    required this.id,
    required this.userId,
    required this.nama,
    required this.nomorHp,
    required this.alamat,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.fotoProfil,
    required this.tahapHafalan,
    required this.peringkat,
    required this.totalPoin,
    required this.createdAt,
    required this.poinUpdatedAt,
    required this.user,
    required this.orangTua,
  });

  final int? id;
  final int? userId;
  final String? nama;
  final String? nomorHp;
  final String? alamat;
  final String? jenisKelamin;
  final DateTime? tanggalLahir;
  final String? fotoProfil;
  final String? tahapHafalan;
  final int? peringkat;
  final int? totalPoin;
  final DateTime? createdAt;
  final DateTime? poinUpdatedAt;
  final User? user;
  final List<OrangTua> orangTua;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      userId: json["userId"],
      nama: json["nama"],
      nomorHp: json["nomorHp"],
      alamat: json["alamat"],
      jenisKelamin: json["jenisKelamin"],
      tanggalLahir: DateTime.tryParse(json["tanggalLahir"] ?? ""),
      fotoProfil: json["fotoProfil"],
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
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "nama": nama,
    "nomorHp": nomorHp,
    "alamat": alamat,
    "jenisKelamin": jenisKelamin,
    "tanggalLahir": tanggalLahir?.toIso8601String(),
    "fotoProfil": fotoProfil,
    "tahapHafalan": tahapHafalan,
    "peringkat": peringkat,
    "totalPoin": totalPoin,
    "createdAt": createdAt?.toIso8601String(),
    "poinUpdatedAt": poinUpdatedAt?.toIso8601String(),
    "user": user?.toJson(),
    "orangTua": orangTua.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $userId, $nama, $nomorHp, $alamat, $jenisKelamin, $tanggalLahir, $fotoProfil, $tahapHafalan, $peringkat, $totalPoin, $createdAt, $poinUpdatedAt, $user, $orangTua, ";
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
  final String? email;
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
