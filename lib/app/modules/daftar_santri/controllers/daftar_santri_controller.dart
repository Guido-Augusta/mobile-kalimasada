import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DaftarSantriController extends GetxController {
  //TODO: Implement DaftarSantriController

  final isLoading = false.obs;
  var santriList = <DaftarSantri>[].obs;
  var searchQuery = ''.obs;

  final int _perPage = 8;
  var currentPage = 1;
  var hasMore = true;
  var isLoadingMore = false;

  var selectedSurah = ''.obs;

  void _resetPagination() {
    currentPage = 1;
    hasMore = true;
    santriList.clear();
  }

  void loadMoreData() async {
    if (isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    currentPage++;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.get(
          Uri.parse(
            'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&search=${searchQuery.value}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-platform': 'mobile',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newItems = List<DaftarSantri>.from(
            data['data'].map((x) => DaftarSantri.fromJson(x)),
          );

          if (newItems.length < _perPage) {
            hasMore = false;
          }

          santriList.addAll(newItems);
        } else {
          currentPage--; // Revert page on error
          Get.snackbar('Error', 'Gagal memuat data tambahan');
        }
      }
    } catch (e) {
      currentPage--; // Revert page on error
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoadingMore = false;
    }
  }

  void fetchData() async {
    _resetPagination();
    isLoading.value = true;

    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        final response = await http.get(
          Uri.parse(
            'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&search=${searchQuery.value}',
          ),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'x-platform': 'mobile',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final items = List<DaftarSantri>.from(
            data['data'].map((x) => DaftarSantri.fromJson(x)),
          );

          if (items.length < _perPage) {
            hasMore = false;
          }

          santriList.value = items;
        } else {
          Get.snackbar('Error', 'Gagal mendapatkan data');
        }
      } else {
        Get.offAllNamed('/login');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void searchSantri() {
    fetchData();
  }
}
