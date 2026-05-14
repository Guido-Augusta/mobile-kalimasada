import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_kalimasada/app/data/constants/api_url.dart';
import 'package:mobile_kalimasada/app/data/models/chart.dart' as c;
import 'package:mobile_kalimasada/app/data/models/santri.dart' as s;
import 'package:mobile_kalimasada/app/modules/ustadz/daftar_santri/controllers/daftar_santri_controller.dart';
import 'package:mobile_kalimasada/app/utils/toast_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/auth_service.dart';

enum ChartType { tambahHafalan, murajaah, tahsin }

class DetailSantriController extends GetxController {
  String token = AuthService.to.token.value;
  Rx<UserRole> userRole = AuthService.to.currentRole;

  // Helper methods
  bool get isAdmin => userRole.value == UserRole.admin;
  bool get isUstadz => userRole.value == UserRole.ustadz;
  bool get isSantri => userRole.value == UserRole.santri;
  bool get isOrtu => userRole.value == UserRole.ortu;

  var isLoading = false.obs;
  var isSaveLoading = false.obs;
  var santriDetail = Rxn<s.Santri>();
  var santriId = Get.arguments;

  var selectedTahap = ''.obs;

  var isLoadingChart = false.obs;
  var isChartError = false.obs;
  var chart = Rxn<c.Chart>();
  var range = '1w'.obs;
  var selectedChartType = ChartType.tambahHafalan.obs;
  var selectedChartMode = 'ayat'.obs;

  DateTime? _lastNoChangeShown;
  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    getSantriDetail(santriId);
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  String getOrangTuaByTipe(List<s.OrangTua> orangTua, String tipe) {
    try {
      final orangTuaByTipe = orangTua.firstWhere(
        (element) => element.tipe?.toLowerCase() == tipe.toLowerCase(),
      );
      return orangTuaByTipe.nama ?? '-';
    } catch (e) {
      return '-';
    }
  }

  String getOrangTuaIdByTipe(List<s.OrangTua> orangTua, String tipe) {
    try {
      final orangTuaByTipe = orangTua.firstWhere(
        (element) => element.tipe?.toLowerCase() == tipe.toLowerCase(),
      );
      return orangTuaByTipe.id?.toString() ?? '-';
    } catch (e) {
      return '-';
    }
  }

  Future<void> getSantriDetail(String santriId, {bool isRefresh = true}) async {
    try {
      isLoading.value = isRefresh;

      if (token.isEmpty) {
        ToastUtils.showErrorToast('Anda tidak terautentikasi');
        Get.offAllNamed('/login');
        return;
      }

      final response = await http
          .get(
            Uri.parse(ApiUrl.santriDetail(santriId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        getChart();
        final data = jsonDecode(response.body);
        final santri = s.Santri.fromJson(data['data']);
        santriDetail.value = santri;
        selectedTahap.value = santri.tahapHafalan ?? '';
      } else {
        ToastUtils.showErrorToast('Gagal mendapatkan data santri');
      }
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void updateTahapHafalan(String tahapHafalan) async {
    if (tahapHafalan == santriDetail.value?.tahapHafalan) {
      final now = DateTime.now();
      if (_lastNoChangeShown == null ||
          now.difference(_lastNoChangeShown!) > Duration(seconds: 3)) {
        _lastNoChangeShown = now;
        ToastUtils.showErrorToast('Tidak ada perubahan data');
      }
      return;
    }
    isSaveLoading.value = true;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final response = await http
          .put(
            Uri.parse(ApiUrl.santriDetail(santriId)),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
            body: jsonEncode({
              'tahapHafalan': tahapHafalan, // Level1, Level2, Level3
            }),
          )
          .timeout(Duration(seconds: 30));
      if (response.statusCode == 200) {
        getSantriDetail(santriId);
        if (Get.isRegistered<DaftarSantriController>()) {
          Get.find<DaftarSantriController>().fetchData();
        }
        Get.back();
        ToastUtils.showSuccessToast('Tahap hafalan berhasil diperbarui');
      } else {
        ToastUtils.showErrorToast('Gagal memperbarui tahap hafalan');
      }
    } catch (e) {
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    } finally {
      isSaveLoading.value = false;
    }
  }

  void getChart() async {
    isLoadingChart.value = true;
    isChartError.value = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      final queryParams = {
        'range': range.value,
        'santriId': santriId.toString(),
        'mode': selectedChartMode.value,
      };

      final uri = Uri.parse(ApiUrl.chart).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'x-platform': 'mobile',
            },
          )
          .timeout(Duration(seconds: 30));
      var data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        chart.value = c.Chart.fromJson(data);
      } else {
        isChartError.value = true;
        ToastUtils.showErrorToast('Gagal mendapatkan data chart');
      }
    } catch (e) {
      isChartError.value = true;
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        ToastUtils.showErrorToast(
          'Terjadi kesalahan\nPeriksa koneksi internet Anda',
        );
      }
    }
    isLoadingChart.value = false;
  }
}
