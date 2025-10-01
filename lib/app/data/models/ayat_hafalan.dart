class AyatHafalan {
  AyatHafalan({
    required this.id,
    required this.nomorAyat,
    required this.arab,
    required this.latin,
    required this.terjemah,
    required this.checked,
  });

  final int? id;
  final int? nomorAyat;
  final String? arab;
  final String? latin;
  final String? terjemah;
  final bool? checked;

  factory AyatHafalan.fromJson(Map<String, dynamic> json) {
    return AyatHafalan(
      id: json["id"],
      nomorAyat: json["nomorAyat"],
      arab: json["arab"],
      latin: json["latin"],
      terjemah: json["terjemah"],
      checked: json["checked"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nomorAyat": nomorAyat,
    "arab": arab,
    "latin": latin,
    "terjemah": terjemah,
    "checked": checked,
  };

  @override
  String toString() {
    return "$id, $nomorAyat, $arab, $latin, $terjemah, $checked, ";
  }
}
