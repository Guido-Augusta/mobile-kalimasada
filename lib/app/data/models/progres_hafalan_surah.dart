// GET http://localhost:5000/api/hafalan/:idSantri/surah

class ProgresHafalanSurah {
  ProgresHafalanSurah({required this.santri, required this.data});

  final Santri? santri;
  final List<Datum> data;

  factory ProgresHafalanSurah.fromJson(Map<String, dynamic> json) {
    return ProgresHafalanSurah(
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
  }) {
    final parts = progress?.split('/') ?? ['0', '0'];
    currentAyat = int.tryParse(parts[0]) ?? 0;
    maxAyat = totalAyat ?? int.tryParse(parts[1]) ?? 0;
    percentage = maxAyat > 0 ? (currentAyat / maxAyat) : 0.0;
    percentageString = (percentage * 100).toStringAsFixed(0);
  }

  final int? id;
  final int? nomor;
  final String? nama;
  final String? namaLatin;
  final int? totalAyat;
  final String? progress;

  late final int currentAyat;
  late final int maxAyat;
  late final double percentage;
  late final String percentageString;

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
    required this.orangTua,
  });

  final int? id;
  final String? nama;
  final String? tahapHafalan;
  final int? totalPoin;
  final List<OrangTua> orangTua;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      id: json["id"],
      nama: json["nama"],
      tahapHafalan: json["tahapHafalan"],
      totalPoin: json["totalPoin"],
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
    "orangTua": orangTua.map((x) => x.toJson()).toList(),
  };

  @override
  String toString() {
    return "$id, $nama, $tahapHafalan, $totalPoin, $orangTua, ";
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
