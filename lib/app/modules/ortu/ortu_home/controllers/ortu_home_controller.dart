import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/models/ortu.dart' as o;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:shared_preferences/shared_preferences.dart';

class OrtuHomeController extends GetxController {
  var isLoading = false.obs;
  var isLoadingChildren = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var ortu = Rxn<o.Ortu>();
  var childrenList = RxList<s.Santri>();

  var currentIndex = 0.obs;
  var islamicQuotes = [
    {
      'quote': 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
      'translation': 'Bacalah dengan (menyebut) nama Tuhanmu yang menciptakan!',
      'source': 'QS. Al-Alaq: 1',
    },
    {
      'quote': 'وَقُل رَّبِّ زِدْنِي عِلْمًا',
      'translation':
          'Dan katakanlah: "Ya Tuhanku, tambahkanlah kepadaku ilmu pengetahuan"',
      'source': 'QS. Thaha: 114',
    },
    {
      'quote': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'translation': 'Sesungguhnya beserta kesulitan ada kemudahan',
      'source': 'QS. Al-Insyirah: 6',
    },
    {
      'quote': 'فَاذْكُرُونِي أَذْكُرْكُمْ',
      'translation': 'Maka ingatlah kepada-Ku, Aku pun akan ingat kepadamu',
      'source': 'QS. Al-Baqarah: 152',
    },
    {
      'quote': 'وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ',
      'translation':
          'Dan tidak ada keberhasilanku melainkan dengan (pertolongan) Allah',
      'source': 'QS. Hud: 88',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    getOrtu();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  void getOrtu() async {
    isLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final roleId = prefs.getString('roleId');
    try {
      final response = await get(
        Uri.parse('http://10.0.2.2:5000/api/ortu/$roleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print(data);
      if (response.statusCode == 200) {
        ortu.value = o.Ortu.fromJson(data['data']);
        fotoProfil.value = getImageUrl(ortu.value!.fotoProfil!);

        if (ortu.value?.santri != null && ortu.value!.santri.isNotEmpty) {
          await getChildrenList();
        }
      } else {
        Get.snackbar('Error', data['message'] ?? 'Gagal mendapatkan data');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred: $e');
    }
    isLoading.value = false;
  }

  Future<void> getChildren(String santriId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await get(
        Uri.parse('http://10.0.2.2:5000/api/santri/$santriId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        childrenList.addIf(
          !childrenList.any((child) => child.id.toString() == santriId),
          s.Santri.fromJson(data['data']),
        );
      } else {
        Get.snackbar('Error', data['message'] ?? 'Gagal mendapatkan data');
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }

  Future<void> getChildrenList() async {
    try {
      isLoadingChildren.value = true;
      childrenList.clear();

      if (ortu.value?.santri != null) {
        for (var santri in ortu.value!.santri) {
          await getChildren(santri.id.toString());
        }
      }
    } catch (e) {
      print(e);
      Get.snackbar('Error', 'Gagal memuat data anak');
    }
    isLoadingChildren.value = false;
  }

  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    try {
      final response = await post(
        Uri.parse('http://10.0.2.2:5000/api/auth/logout/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      var data = jsonDecode(response.body);
      print(response.statusCode);
      print(data);
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
        Get.offAllNamed('/login');
        Get.snackbar('Success', 'Logout berhasil');
      } else {
        Get.snackbar('Error', data['message'] ?? 'Logout gagal');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    }
  }
}
