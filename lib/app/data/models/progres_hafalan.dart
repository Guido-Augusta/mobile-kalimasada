// GET http://localhost:5000/api/hafalan/:idSantri/surah

class ProgresHafalan {
  ProgresHafalan({required this.santri, required this.data});

  final Santri? santri;
  final List<Datum> data;

  factory ProgresHafalan.fromJson(Map<String, dynamic> json) {
    return ProgresHafalan(
      santri: json["santri"] == null ? null : Santri.fromJson(json["santri"]),
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
    "santri": santri?.toJson(),
    "data": data.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$santri, $data, ";
  }
}

class Datum {
  Datum({
    required this.id,
    required this.nomor,
    required this.nama,
    required this.namaLatin,
    required this.totalAyat,
    required this.progress,
  });

  final int? id;
  final int? nomor;
  final String? nama;
  final String? namaLatin;
  final int? totalAyat;
  final String? progress;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      nomor: json["nomor"],
      nama: json["nama"],
      namaLatin: json["namaLatin"],
      totalAyat: json["totalAyat"],
      progress: json["progress"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomor": nomor,
    "nama": nama,
    "namaLatin": namaLatin,
    "totalAyat": totalAyat,
    "progress": progress,
  };

  @override
  String toString() {
    return "$id, $nomor, $nama, $namaLatin, $totalAyat, $progress, ";
  }
}

class Santri {
  Santri({
    required this.id,
    required this.nama,
    required this.tahapHafalan,
    required this.totalPoin,
    required this.noInduk,
    required this.orangTua,
  });

  final int? id;
  final String? nama;
  final String? tahapHafalan;
  final int? totalPoin;
  final String? noInduk;
  final List<OrangTua> orangTua;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      nama: json["nama"],
      tahapHafalan: json["tahapHafalan"],
      totalPoin: json["totalPoin"],
      noInduk: json["noInduk"],
      orangTua: json["orangTua"] == null
          ? []
          : List<OrangTua>.from(
              json["orangTua"]!.map((x) => OrangTua.fromJson(x)),
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "tahapHafalan": tahapHafalan,
    "totalPoin": totalPoin,
    "noInduk": noInduk,
    "orangTua": orangTua.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $nama, $tahapHafalan, $totalPoin, $noInduk, $orangTua, ";
  }
}

class OrangTua {
  OrangTua({required this.id, required this.nama, required this.user});

  final int? id;
  final String? nama;
  final User? user;

  factory OrangTua.fromJson(Map<String, dynamic> json) {
    return OrangTua(
      id: json["id"],
      nama: json["nama"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "user": user?.toJson(),
  };

  @override
  String toString() {
    return "$id, $nama, $user, ";
  }
}

class User {
  User({required this.email});

  final String? email;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json["email"]);
  }

  Map<String, dynamic> toJson() => {"email": email};

  @override
  String toString() {
    return "$email, ";
  }
}
