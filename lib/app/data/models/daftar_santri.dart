// GET http://localhost:5000/api/santri?page=1&limit=10&tahapHafalan=level1

class DaftarSantri {
  DaftarSantri({required this.data, required this.totalData});

  final List<Datum> data;
  final int? totalData;

  factory DaftarSantri.fromJson(Map<String, dynamic> json) {
    return DaftarSantri(
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      totalData: json["totalData"],
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x.toJson()).toList(),
    "totalData": totalData,
  };

  @override
  String toString() {
    return "$data, $totalData, ";
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
    required this.tanggalLahir,
    required this.fotoProfil,
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
  final String? nomorHp;
  final String? alamat;
  final String? jenisKelamin;
  final DateTime? tanggalLahir;
  final String? fotoProfil;
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
      nomorHp: json["nomorHp"],
      alamat: json["alamat"],
      jenisKelamin: json["jenisKelamin"],
      tanggalLahir: DateTime.tryParse(json["tanggalLahir"] ?? ""),
      fotoProfil: json["fotoProfil"],
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
    "nomorHp": nomorHp,
    "alamat": alamat,
    "jenisKelamin": jenisKelamin,
    "tanggalLahir": tanggalLahir?.toIso8601String(),
    "fotoProfil": fotoProfil,
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
    return "$id, $userId, $nama, $nomorHp, $alamat, $jenisKelamin, $tanggalLahir, $fotoProfil, $tahapHafalan, $totalPoin, $peringkat, $createdAt, $poinUpdatedAt, $user, $orangTua, ";
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
