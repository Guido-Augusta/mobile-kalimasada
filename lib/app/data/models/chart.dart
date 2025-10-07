class Chart {
  Chart({required this.santri, required this.data});

  final Santri? santri;
  final List<Datum> data;

  factory Chart.fromJson(Map<String, dynamic> json) {
    return Chart(
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
    required this.tanggal,
    required this.tambahHafalan,
    required this.murajaah,
  });

  final DateTime? tanggal;
  final int? tambahHafalan;
  final int? murajaah;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      tanggal: DateTime.tryParse(json["tanggal"] ?? ""),
      tambahHafalan: json["tambahHafalan"],
      murajaah: json["murajaah"],
    );
  }

  Map<String, dynamic> toJson() => {
    "tanggal":
        "${tanggal?.year.toString().padLeft(4, '0')}-${tanggal?.month.toString().padLeft(2, '0')}-${tanggal?.day.toString().padLeft(2, '0')}",
    "tambahHafalan": tambahHafalan,
    "murajaah": murajaah,
  };

  @override
  String toString() {
    return "$tanggal, $tambahHafalan, $murajaah, ";
  }
}

class Santri {
  Santri({
    required this.nama,
    required this.tahapHafalan,
    required this.totalPoin,
  });

  final String? nama;
  final String? tahapHafalan;
  final int? totalPoin;

  factory Santri.fromJson(Map<String, dynamic> json) {
    return Santri(
      nama: json["nama"],
      tahapHafalan: json["tahapHafalan"],
      totalPoin: json["totalPoin"],
    );
  }

  Map<String, dynamic> toJson() => {
    "nama": nama,
    "tahapHafalan": tahapHafalan,
    "totalPoin": totalPoin,
  };

  @override
  String toString() {
    return "$nama, $tahapHafalan, $totalPoin, ";
  }
}
