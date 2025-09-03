class DaftarSantri {
  DaftarSantri({
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
  final User? user;
  final OrangTua? orangTua;

  factory DaftarSantri.fromJson(Map<String, dynamic> json) {
    return DaftarSantri(
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
    "user": user?.toJson(),
    "orangTua": orangTua?.toJson(),
  };

  @override
  String toString() {
    return "$id, $userId, $ortuId, $nama, $nomorHp, $alamat, $jenisKelamin, $tanggalLahir, $fotoProfil, $tingkatan, $tahapHafalan, $totalPoin, $peringkat, $user, $orangTua, ";
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
