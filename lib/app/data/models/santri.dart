class Santri {
  Santri({
    required this.id,
    required this.userId,
    required this.ortuId,
    required this.nama,
    required this.nomorHp,
    required this.alamat,
    required this.jenisKelamin,
    required this.tanggalLahir,
    required this.fotoProfil,
    required this.tingkatan,
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
  final int? ortuId;
  final String? nama;
  final String? nomorHp;
  final String? alamat;
  final String? jenisKelamin;
  final DateTime? tanggalLahir;
  final String? fotoProfil;
  final String? tingkatan;
  final String? tahapHafalan;
  final int? totalPoin;
  final int? peringkat;
  final DateTime? createdAt;
  final DateTime? poinUpdatedAt;
  final User? user;
  final OrangTua? orangTua;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      userId: json["userId"],
      ortuId: json["ortuId"],
      nama: json["nama"],
      nomorHp: json["nomorHp"],
      alamat: json["alamat"],
      jenisKelamin: json["jenisKelamin"],
      tanggalLahir: DateTime.tryParse(json["tanggalLahir"] ?? ""),
      fotoProfil: json["fotoProfil"],
      tingkatan: json["tingkatan"],
      tahapHafalan: json["tahapHafalan"],
      totalPoin: json["totalPoin"],
      peringkat: json["peringkat"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      poinUpdatedAt: DateTime.tryParse(json["poinUpdatedAt"] ?? ""),
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      orangTua: json["orangTua"] == null
          ? null
          : OrangTua.fromJson(json["orangTua"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "userId": userId,
    "ortuId": ortuId,
    "nama": nama,
    "nomorHp": nomorHp,
    "alamat": alamat,
    "jenisKelamin": jenisKelamin,
    "tanggalLahir": tanggalLahir?.toIso8601String(),
    "fotoProfil": fotoProfil,
    "tingkatan": tingkatan,
    "tahapHafalan": tahapHafalan,
    "totalPoin": totalPoin,
    "peringkat": peringkat,
    "createdAt": createdAt?.toIso8601String(),
    "poinUpdatedAt": poinUpdatedAt?.toIso8601String(),
    "user": user?.toJson(),
    "orangTua": orangTua?.toJson(),
  };

  @override
  String toString() {
    return "$id, $userId, $ortuId, $nama, $nomorHp, $alamat, $jenisKelamin, $tanggalLahir, $fotoProfil, $tingkatan, $tahapHafalan, $totalPoin, $peringkat, $createdAt, $poinUpdatedAt, $user, $orangTua, ";
  }
}

class OrangTua {
  OrangTua({required this.id, required this.nama});

  final int? id;
  final String? nama;

  factory OrangTua.fromJson(Map<String, dynamic> json) {
    return OrangTua(id: json["id"], nama: json["nama"]);
  }

  Map<String, dynamic> toJson() => {"id": id, "nama": nama};

  @override
  String toString() {
    return "$id, $nama, ";
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
