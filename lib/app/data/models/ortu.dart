class Ortu {
  Ortu({
    required this.id,
    required this.userId,
    required this.nama,
    required this.nomorHp,
    required this.alamat,
    required this.jenisKelamin,
    required this.fotoProfil,
    required this.tipe,
    required this.user,
    required this.santri,
  });

  final int? id;
  final int? userId;
  final String? nama;
  final String? nomorHp;
  final String? alamat;
  final String? jenisKelamin;
  final String? fotoProfil;
  final String? tipe;
  final User? user;
  final List<Santri> santri;

  factory Ortu.fromJson(Map<String, dynamic> json) {
    return Ortu(
      id: json["id"],
      userId: json["userId"],
      nama: json["nama"],
      nomorHp: json["nomorHp"],
      alamat: json["alamat"],
      jenisKelamin: json["jenisKelamin"],
      fotoProfil: json["fotoProfil"],
      tipe: json["tipe"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      santri: json["santri"] == null
          ? []
          : List<Santri>.from(json["santri"]!.map((x) => Santri.fromJson(x))),
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
    "tipe": tipe,
    "user": user?.toJson(),
    "santri": santri.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $userId, $nama, $nomorHp, $alamat, $jenisKelamin, $fotoProfil, $tipe, $user, $santri, ";
  }
}

class Santri {
  Santri({required this.id, required this.nama});

  final int? id;
  final String? nama;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(id: json["id"], nama: json["nama"]);
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
