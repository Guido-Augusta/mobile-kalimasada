import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/ortu/ortu_home/bindings/ortu_home_binding.dart';
import '../modules/ortu/ortu_home/views/ortu_home_view.dart';
import '../modules/ustadz/progres_hafalan/bindings/progres_hafalan_binding.dart';
import '../modules/ustadz/progres_hafalan/views/progres_hafalan_view.dart';
import '../modules/santri/santri_home/bindings/santri_home_binding.dart';
import '../modules/santri/santri_home/views/santri_home_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/ustadz/daftar_santri/bindings/daftar_santri_binding.dart';
import '../modules/ustadz/daftar_santri/views/daftar_santri_view.dart';
import '../modules/ustadz/daftar_surah/bindings/daftar_surah_binding.dart';
import '../modules/ustadz/daftar_surah/views/daftar_surah_view.dart';
import '../modules/ustadz/detail_santri/bindings/detail_santri_binding.dart';
import '../modules/ustadz/detail_santri/views/detail_santri_view.dart';
import '../modules/ustadz/ustadz_home/bindings/ustadz_home_binding.dart';
import '../modules/ustadz/ustadz_home/views/ustadz_home_view.dart';
import '../modules/ustadz/ustadz_profile/bindings/ustadz_profile_binding.dart';
import '../modules/ustadz/ustadz_profile/views/ustadz_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.HOME, page: () => HomeView(), binding: HomeBinding()),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.SANTRI_HOME,
      page: () => const SantriHomeView(),
      binding: SantriHomeBinding(),
    ),
    GetPage(
      name: _Paths.USTADZ_HOME,
      page: () => const UstadzHomeView(),
      binding: UstadzHomeBinding(),
    ),
    GetPage(
      name: _Paths.ORTU_HOME,
      page: () => const OrtuHomeView(),
      binding: OrtuHomeBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_SANTRI,
      page: () => const DaftarSantriView(),
      binding: DaftarSantriBinding(),
    ),
    GetPage(
      name: _Paths.USTADZ_PROFILE,
      page: () => const UstadzProfileView(),
      binding: UstadzProfileBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_SURAH,
      page: () => const DaftarSurahView(),
      binding: DaftarSurahBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_SANTRI,
      page: () => const DetailSantriView(),
      binding: DetailSantriBinding(),
    ),
    GetPage(
      name: _Paths.PROGRES_HAFALAN,
      page: () => const ProgresHafalanView(),
      binding: ProgresHafalanBinding(),
    ),
  ];
}
