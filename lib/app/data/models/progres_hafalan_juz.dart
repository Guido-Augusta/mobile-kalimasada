// GET http://localhost:5000/api/hafalan/:idSantri/juz

class ProgresHafalanJuz {
  ProgresHafalanJuz({required this.santri, required this.data});

  final Santri? santri;
  final List<Datum> data;

  factory ProgresHafalanJuz.fromJson(Map<String, dynamic> json) {
    return ProgresHafalanJuz(
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
    required this.juz,
    required this.mulaiDari,
    required this.progress,
    required this.totalAyat,
  }) {
    final parts = progress?.split('/') ?? ['0', '0'];
    currentAyat = int.tryParse(parts[0]) ?? 0;
    maxAyat = totalAyat ?? int.tryParse(parts[1]) ?? 0;
    percentage = maxAyat > 0 ? (currentAyat / maxAyat) : 0.0;
    percentageString = (percentage * 100).toStringAsFixed(0);
  }

  final int? juz;
  final MulaiDari? mulaiDari;
  final String? progress;
  final int? totalAyat;

  late final int currentAyat;
  late final int maxAyat;
  late final double percentage;
  late final String percentageString;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      juz: json["juz"],
      mulaiDari: json["mulai_dari"] == null
          ? null
          : MulaiDari.fromJson(json["mulai_dari"]),
      progress: json["progress"],
      totalAyat: json["totalAyat"],
    );
  }

  Map<String, dynamic> toJson() => {
    "juz": juz,
    "mulai_dari": mulaiDari?.toJson(),
    "progress": progress,
    "totalAyat": totalAyat,
  };

  @override
  String toString() {
    return "$juz, $mulaiDari, $progress, $totalAyat, ";
  }
}

class MulaiDari {
  MulaiDari({required this.surah, required this.ayat});

  final Surah? surah;
  final int? ayat;

  factory MulaiDari.fromJson(Map<String, dynamic> json) {
    return MulaiDari(
      surah: json["surah"] == null ? null : Surah.fromJson(json["surah"]),
      ayat: json["ayat"],
    );
  }

  Map<String, dynamic> toJson() => {"surah": surah?.toJson(), "ayat": ayat};

  @override
  String toString() {
    return "$surah, $ayat, ";
  }
}

class Surah {
  Surah({required this.nomor, required this.nama, required this.namaLatin});

  final int? nomor;
  final String? nama;
  final String? namaLatin;

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      nomor: json["nomor"],
      nama: json["nama"],
      namaLatin: json["nama_latin"],
    );
  }

  Map<String, dynamic> toJson() => {
    "nomor": nomor,
    "nama": nama,
    "nama_latin": namaLatin,
  };

  @override
  String toString() {
    return "$nomor, $nama, $namaLatin, ";
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
