class DaftarOrtu {
  DaftarOrtu({required this.data});

  final List<Datum> data;

  factory DaftarOrtu.fromJson(Map<String, dynamic> json) {
    return DaftarOrtu(
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$data, ";
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
    required this.tipe,
    required this.user,
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

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      userId: json["userId"],
      nama: json["nama"],
      nomorHp: json["nomorHp"],
      alamat: json["alamat"],
      jenisKelamin: json["jenisKelamin"],
      fotoProfil: json["fotoProfil"],
      tipe: json["tipe"],
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
    "tipe": tipe,
    "user": user?.toJson(),
  };

  @override
  String toString() {
    return "$id, $userId, $nama, $nomorHp, $alamat, $jenisKelamin, $fotoProfil, $tipe, $user, ";
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
