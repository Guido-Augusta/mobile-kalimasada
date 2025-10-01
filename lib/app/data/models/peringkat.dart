class Peringkat {
  Peringkat({required this.data});

  final List<Datum> data;

  factory Peringkat.fromJson(Map<String, dynamic> json) {
    return Peringkat(
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
    required this.nama,
    required this.totalPoin,
    required this.peringkat,
    required this.tahapHafalan,
    required this.fotoProfil,
  });

  final int? id;
  final String? nama;
  final int? totalPoin;
  final int? peringkat;
  final String? tahapHafalan;
  final String? fotoProfil;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      nama: json["nama"],
      totalPoin: json["totalPoin"],
      peringkat: json["peringkat"],
      tahapHafalan: json["tahapHafalan"],
      fotoProfil: json["fotoProfil"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nama": nama,
    "totalPoin": totalPoin,
    "peringkat": peringkat,
    "tahapHafalan": tahapHafalan,
    "fotoProfil": fotoProfil,
  };

  @override
  String toString() {
    return "$id, $nama, $totalPoin, $peringkat, $tahapHafalan, $fotoProfil, ";
  }
}
