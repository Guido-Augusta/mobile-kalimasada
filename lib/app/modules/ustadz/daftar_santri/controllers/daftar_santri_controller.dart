import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_kalimasada/app/data/models/daftar_santri.dart';
import 'package:mobile_kalimasada/app/data/models/surah.dart' as s;
import 'package:mobile_kalimasada/app/data/models/ayat_hafalan.dart';
import 'package:mobile_kalimasada/app/data/models/detail_hafalan.dart' as dh;
import 'package:searchfield/searchfield.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:toastification/toastification.dart';

class DaftarSantriController extends GetxController {
  final isLoading = false.obs;
  final isSaveLoading = false.obs;
  var santriList = <Datum>[].obs;
  var searchQuery = ''.obs;
  var tahapHafalan = 'level1'.obs;

  final int _perPage = 10;
  var currentPage = 1;
  var hasMore = true.obs;
  var isLoadingMore = false.obs;

  var isLoadingSurah = false.obs;
  var surahList = <s.Surah>[].obs;
  var selectedSurahHafalan = Rxn<SearchFieldListItem<s.Surah>>();
  var selectedSurahMurajaah = Rxn<SearchFieldListItem<s.Surah>>();
  var detailHafalan = Rx<dh.DetailHafalan?>(null);

  var isLoadingAyat = false.obs;
  var inputJumlahAyatController = TextEditingController();
  var ayatList = <AyatHafalan>[].obs;
  var selectedAyatMulai = Rxn<AyatHafalan>();
  var selectedAyatAkhir = Rxn<AyatHafalan>();

  var statusSetoran = ''.obs;

  var catatanController = TextEditingController();

  final formKeyHafalan = GlobalKey<FormState>();
  final formKeyMurajaah = GlobalKey<FormState>();

  final scrollController = ScrollController();

  DateTime? _lastErrorShown;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    _setupScrollController();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _resetPagination() {
    currentPage = 1;
    hasMore.value = true;
    santriList.clear();
  }

  void _setupScrollController() {
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        if (hasMore.value && !isLoadingMore.value) {
          loadMoreData();
        }
      }
    });
  }

  void loadMoreData() async {
    if (isLoadingMore.value || !hasMore.value) return;

    try {
      isLoadingMore.value = true;
      currentPage++;

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Anda tidak terautentikasi',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          applyBlurEffect: true,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&tahapHafalan=${tahapHafalan.value}&search=${searchQuery.value}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newItems = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (newItems.length < _perPage) {
          hasMore.value = false;
        }

        santriList.addAll(newItems);
      } else {
        currentPage--; // Revert page on error
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gagal memuat data tambahan',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      currentPage--; // Revert page on error
      final now = DateTime.now();
      if (_lastErrorShown == null ||
          now.difference(_lastErrorShown!) > Duration(seconds: 3)) {
        _lastErrorShown = now;
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            direction: Axis.horizontal,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gagal memuat data\nPeriksa koneksi internet Anda',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 2),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void fetchData() async {
    try {
      isLoading.value = true;
      _resetPagination();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Anda tidak terautentikasi',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
        Get.offAllNamed('/login');
        return;
      }

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/santri?page=$currentPage&limit=$_perPage&tahapHafalan=${tahapHafalan.value}&search=${searchQuery.value}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = List<Datum>.from(
          data['data'].map((x) => Datum.fromJson(x)),
        );

        if (items.length < _perPage) {
          hasMore.value = false;
        }

        santriList.value = items;
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Gagal memuat data', style: TextStyle(color: Colors.white)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      toastification.show(
        context: Get.context!,
        title: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Terjadi kesalahan\nPeriksa koneksi internet Anda',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        icon: Icon(Icons.error, color: Colors.white),
        showIcon: true,
        backgroundColor: Color(0xFF6B6B6B),
        borderSide: BorderSide.none,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(milliseconds: 1500),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchSurahs() async {
    try {
      isLoadingSurah.value = true;
      final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/api/alquran/'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> surahsData = data['data'];
        surahList.value = surahsData
            .map((json) => s.Surah.fromJson(json))
            .toList();
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gagal memuat data surah',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      toastification.show(
        context: Get.context!,
        title: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Terjadi kesalahan\nPeriksa koneksi internet Anda',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        icon: Icon(Icons.error, color: Colors.white),
        showIcon: true,
        backgroundColor: Color(0xFF6B6B6B),
        borderSide: BorderSide.none,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(milliseconds: 1500),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isLoadingSurah.value = false;
    }
  }

  Future<void> fetchAyatMurajaahForSurah(
    String santriId,
    String surahId,
  ) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    try {
      isLoadingAyat.value = true;
      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/$santriId/surah/$surahId?mode=murajaah',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> ayatData = data['ayat'];
        ayatList.value = ayatData
            .map((json) => AyatHafalan.fromJson(json))
            .toList();
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gagal memuat data ayat',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      toastification.show(
        context: Get.context!,
        title: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Terjadi kesalahan\nPeriksa koneksi internet Anda',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        icon: Icon(Icons.error, color: Colors.white),
        showIcon: true,
        backgroundColor: Color(0xFF6B6B6B),
        borderSide: BorderSide.none,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(milliseconds: 1500),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isLoadingAyat.value = false;
    }
  }

  void onSurahSelected(
    s.Surah? newSurah,
    String santriId,
    String statusSetoran,
  ) {
    // Reset selections when changing surah
    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;

    if (newSurah != null) {
      if (statusSetoran == 'TambahHafalan') {
        getDetailTambahHafalan(santriId, newSurah.id.toString());
      } else if (statusSetoran == 'Murajaah') {
        // selectedSurahMurajaah.value = newSurah;
        fetchAyatMurajaahForSurah(santriId, newSurah.id.toString());
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Invalid status setoran',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    }
  }

  void getDetailTambahHafalan(String santriId, String surahId) async {
    try {
      isLoading.value = true;
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5000/api/hafalan/$santriId/surah/$surahId?mode=tambah',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        detailHafalan.value = dh.DetailHafalan.fromJson(data);
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text('Gagal memuat ayat', style: TextStyle(color: Colors.white)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      toastification.show(
        context: Get.context!,
        title: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Terjadi kesalahan saat memuat ayat\nPeriksa koneksi internet Anda',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        icon: Icon(Icons.error, color: Colors.white),
        showIcon: true,
        backgroundColor: Color(0xFF6B6B6B),
        borderSide: BorderSide.none,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(milliseconds: 1500),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void saveHafalan(String santriId) async {
    isSaveLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ustadzId = prefs.getString('roleId');
    var ayatIds = [];

    // Logika otomatis mengisi ayatIds
    if (detailHafalan.value != null && detailHafalan.value!.ayat.isNotEmpty) {
      // 1. Cari ayat terakhir yang sudah dihafalkan (checked = true)
      int lastHafalanAyatNumber = 0;
      for (var ayat in detailHafalan.value!.ayat) {
        if (ayat.checked == true) {
          lastHafalanAyatNumber = ayat.nomorAyat ?? 0;
        }
      }

      // 2. Dapatkan daftar ayat yang belum dihafalkan (checked = false)
      List<dh.Ayat> uncheckedAyats = detailHafalan.value!.ayat
          .where((ayat) => ayat.checked == false)
          .toList();

      // 3. Urutkan berdasarkan nomor ayat
      uncheckedAyats.sort(
        (a, b) => (a.nomorAyat ?? 0).compareTo(b.nomorAyat ?? 0),
      );

      // 4. Ambil ayat-ayat berikutnya sesuai jumlah yang diinput
      int jumlahAyatDitambahkan = int.parse(inputJumlahAyatController.text);
      if (jumlahAyatDitambahkan <= 0) {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Jumlah ayat harus lebih dari 0',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 1500),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
        isSaveLoading.value = false;
        return;
      }
      if (jumlahAyatDitambahkan > 0) {
        // Cari ayat pertama yang belum dihafalkan setelah ayat terakhir yang dihafalkan
        List<dh.Ayat> ayatsToBeAdded = [];
        bool foundStartingPoint = false;

        for (var ayat in uncheckedAyats) {
          if (!foundStartingPoint) {
            // Cari ayat pertama yang lebih besar dari ayat terakhir yang dihafalkan
            if ((ayat.nomorAyat ?? 0) > lastHafalanAyatNumber) {
              foundStartingPoint = true;
            }
          }

          if (foundStartingPoint) {
            ayatsToBeAdded.add(ayat);
            if (ayatsToBeAdded.length >= jumlahAyatDitambahkan) {
              break;
            }
          }
        }

        // 5. Ambil ID dari ayat-ayat yang akan ditambahkan
        ayatIds = ayatsToBeAdded.map((ayat) => ayat.id).toList();
      }
    }

    print('santriId: $santriId');
    print('ustadzId: $ustadzId');
    print('ayatIds: $ayatIds');
    print('statusSetoran: ${statusSetoran.value}');
    print('catatan: ${catatanController.text}');
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/hafalan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'ustadzId': ustadzId,
          'ayatIds': ayatIds,
          'status': statusSetoran.value,
          'catatan': catatanController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        Get.back();
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text(
                'Hafalan berhasil ditambahkan',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.check_circle_outline_rounded, color: Colors.green),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 2000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.success,
          style: ToastificationStyle.simple,
        );
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gagal menambahkan hafalan',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 2000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      print(e);
      toastification.show(
        context: Get.context!,
        title: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Terjadi kesalahan saat menambahkan hafalan\nPeriksa koneksi internet Anda',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        icon: Icon(Icons.error, color: Colors.white),
        showIcon: true,
        backgroundColor: Color(0xFF6B6B6B),
        borderSide: BorderSide.none,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(milliseconds: 2000),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isSaveLoading.value = false;
    }

    ayatIds = [];
    inputJumlahAyatController.text = '';
    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;
    selectedSurahHafalan.value = null;
    statusSetoran.value = '';
    catatanController.clear();
    isSaveLoading.value = false;
  }

  void saveMurajaah(String santriId) async {
    isSaveLoading.value = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final ustadzId = prefs.getString('roleId');
    var ayatIds = [];
    if (selectedAyatMulai.value != null && selectedAyatAkhir.value != null) {
      ayatIds = List.generate(
        selectedAyatAkhir.value!.id! - selectedAyatMulai.value!.id! + 1,
        (index) => selectedAyatMulai.value!.id! + index,
      );
    }
    print(santriId);
    print(ustadzId);
    print(ayatIds);
    print(statusSetoran.value);
    print(catatanController.text);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/api/hafalan'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'x-platform': 'mobile',
        },
        body: jsonEncode({
          'santriId': santriId,
          'ustadzId': ustadzId,
          'ayatIds': ayatIds,
          'status': statusSetoran.value,
          'catatan': catatanController.text,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        Get.back();
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.green),
              SizedBox(width: 10),
              Text(
                'Murajaah berhasil ditambahkan',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.check_circle_outline_rounded, color: Colors.green),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 2000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.success,
          style: ToastificationStyle.simple,
        );
      } else {
        toastification.show(
          context: Get.context!,
          title: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gagal menambahkan hafalan',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          icon: Icon(Icons.error, color: Colors.white),
          showIcon: true,
          backgroundColor: Color(0xFF6B6B6B),
          borderSide: BorderSide.none,
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(milliseconds: 2000),
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          animationBuilder: (context, animation, alignment, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          type: ToastificationType.error,
          style: ToastificationStyle.simple,
        );
      }
    } catch (e) {
      print(e);
      toastification.show(
        context: Get.context!,
        title: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Terjadi kesalahan saat menambahkan murajaah\nPeriksa koneksi internet Anda',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        icon: Icon(Icons.error, color: Colors.white),
        showIcon: true,
        backgroundColor: Color(0xFF6B6B6B),
        borderSide: BorderSide.none,
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(milliseconds: 2000),
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        animationBuilder: (context, animation, alignment, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        type: ToastificationType.error,
        style: ToastificationStyle.simple,
      );
    } finally {
      isSaveLoading.value = false;
    }

    selectedAyatMulai.value = null;
    selectedAyatAkhir.value = null;
    selectedSurahMurajaah.value = null;
    statusSetoran.value = '';
    catatanController.clear();
  }

  String getImageUrl(String imageUrl) {
    String newImageUrl = imageUrl.replaceFirst('localhost', '10.0.2.2');
    return newImageUrl;
  }

  String getTahapanSantri(String tahapan) {
    if (tahapan == 'Level1') {
      return 'Level 1';
    } else if (tahapan == 'Level2') {
      return 'Level 2';
    } else if (tahapan == 'Level3') {
      return 'Level 3';
    } else {
      return 'Belum ada tahapan';
    }
  }

  String getTahapanFilter(String tahapan) {
    if (tahapan == 'level1') {
      return 'level 1';
    } else if (tahapan == 'level2') {
      return 'level 2';
    } else if (tahapan == 'level3') {
      return 'level 3';
    } else {
      return 'Tidak ada tahapan';
    }
  }
}
