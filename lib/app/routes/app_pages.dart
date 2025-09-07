import 'package:get/get.dart';

import '../modules/daftar_santri/bindings/daftar_santri_binding.dart';
import '../modules/daftar_santri/views/daftar_santri_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/ortu_home/bindings/ortu_home_binding.dart';
import '../modules/ortu_home/views/ortu_home_view.dart';
import '../modules/santri_home/bindings/santri_home_binding.dart';
import '../modules/santri_home/views/santri_home_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/ustadz_home/bindings/ustadz_home_binding.dart';
import '../modules/ustadz_home/views/ustadz_home_view.dart';
import '../modules/ustadz_profile/bindings/ustadz_profile_binding.dart';
import '../modules/ustadz_profile/views/ustadz_profile_view.dart';

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
  ];
}
