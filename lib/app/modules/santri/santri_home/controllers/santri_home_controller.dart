import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ChartType { hafalanBaru, murajaah }

class SantriHomeController extends GetxController {
  var isLoading = false.obs;
  var isLoadingChart = false.obs;
  var fotoProfil =
      'https://res.cloudinary.com/dqrppoiza/image/upload/v1754292060/placeholder_profile_ff5xwy.jpg'
          .obs;

  var santri = Rxn<s.Santri>();
  var chart = Rxn<c.Chart>();
  var range = '1w'.obs;

  var selectedChartType = ChartType.hafalanBaru.obs;

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
    getSantri();
    getChart();
  }

  void updateRange(String newRange) {
    range.value = newRange;
    getChart();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  Future<void> getSantri() async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final roleId = prefs.getString('roleId');

      final response = await get(
        Uri.parse('http://10.0.2.2:5000/api/santri/$roleId'),
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
        santri.value = s.Santri.fromJson(data['data']);
        fotoProfil.value = getImageUrl(santri.value!.fotoProfil!);
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
    isLoading.value = false;
  }

  void getChart() async {
    try {
      isLoadingChart.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final roleId = prefs.getString('roleId');

      final response = await get(
        Uri.parse(
          'http://10.0.2.2:5000/api/chart?range=$range&santriId=$roleId',
        ),
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
        chart.value = c.Chart.fromJson(data);
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data chart');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
    isLoadingChart.value = false;
  }

  Future<void> logout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      final response = await post(
        Uri.parse('http://10.0.2.2:5000/api/auth/logout/$userId'),
        headers: {'Content-Type': 'application/json'},
      );
      var data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        await prefs.remove('userId');
        await prefs.remove('roleId');
        Get.offAllNamed('/login');
        ToastUtils.showSuccessToast('Logout berhasil');
      } else {
        ToastUtils.showErrorToast('Logout gagal');
      }
    } catch (e) {
      ToastUtils.showErrorToast(
        'Terjadi kesalahan\nPeriksa koneksi internet Anda',
      );
    }
  }
}
