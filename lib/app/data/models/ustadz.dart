// GET http://localhost:5000/api/ustadz/:ustadzId

class Ustadz {
  Ustadz({
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

  factory Ustadz.fromJson(Map<String, dynamic> json) {
    return Ustadz(
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
