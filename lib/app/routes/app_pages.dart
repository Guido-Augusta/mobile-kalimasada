import 'package:get/get.dart';

import '../middleware/auth_middleware.dart';
import '../modules/admin/admin_home/bindings/admin_home_binding.dart';
import '../modules/admin/admin_home/views/admin_home_view.dart';
import '../modules/admin/daftar_ortu/bindings/daftar_ortu_binding.dart';
import '../modules/admin/daftar_ortu/views/daftar_ortu_view.dart';
import '../modules/admin/edit_santri/bindings/edit_santri_binding.dart';
import '../modules/admin/edit_santri/views/edit_santri_view.dart';
import '../modules/admin/tambah_ortu/bindings/tambah_ortu_binding.dart';
import '../modules/admin/tambah_ortu/views/tambah_ortu_view.dart';
import '../modules/admin/tambah_santri/bindings/tambah_santri_binding.dart';
import '../modules/admin/tambah_santri/views/tambah_santri_view.dart';
import '../modules/auth/change_password/bindings/change_password_binding.dart';
import '../modules/auth/change_password/views/change_password_view.dart';
import '../modules/auth/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/auth/forgot_password/views/forgot_password_view.dart';
import '../modules/auth/login/bindings/login_binding.dart';
import '../modules/auth/login/views/login_view.dart';
import '../modules/auth/splash/bindings/splash_binding.dart';
import '../modules/auth/splash/views/splash_view.dart';
import '../modules/admin/edit_ortu/bindings/edit_ortu_binding.dart';
import '../modules/admin/edit_ortu/views/edit_ortu_view.dart';
import '../modules/main/ortu_main/bindings/ortu_main_binding.dart';
import '../modules/main/ortu_main/views/ortu_main_view.dart';
import '../modules/main/santri_main/bindings/santri_main_binding.dart';
import '../modules/main/santri_main/views/santri_main_view.dart';
import '../modules/main/ustadz_main/bindings/ustadz_main_binding.dart';
import '../modules/main/ustadz_main/views/ustadz_main_view.dart';
import '../modules/ortu/detail_ortu/bindings/detail_ortu_binding.dart';
import '../modules/ortu/detail_ortu/views/detail_ortu_view.dart';
import '../modules/ortu/ortu_home/bindings/ortu_home_binding.dart';
import '../modules/ortu/ortu_home/views/ortu_home_view.dart';
import '../modules/ortu/ortu_profile/bindings/ortu_profile_binding.dart';
import '../modules/ortu/ortu_profile/views/ortu_profile_view.dart';
import '../modules/quran/alquran/bindings/alquran_binding.dart';
import '../modules/quran/alquran/views/alquran_view.dart';
import '../modules/quran/detail_surah/bindings/detail_surah_binding.dart';
import '../modules/quran/detail_surah/views/detail_surah_view.dart';
import '../modules/santri/detail_progres/bindings/detail_progres_binding.dart';
import '../modules/santri/detail_progres/views/detail_progres_view.dart';
import '../modules/santri/doa_khatam/bindings/doa_khatam_binding.dart';
import '../modules/santri/doa_khatam/views/doa_khatam_view.dart';
import '../modules/santri/santri_home/bindings/santri_home_binding.dart';
import '../modules/santri/santri_home/views/santri_home_view.dart';
import '../modules/santri/santri_profile/bindings/santri_profile_binding.dart';
import '../modules/santri/santri_profile/views/santri_profile_view.dart';
import '../modules/ustadz/daftar_santri/bindings/daftar_santri_binding.dart';
import '../modules/ustadz/daftar_santri/views/daftar_santri_view.dart';
import '../modules/ustadz/detail_riwayat_hafalan/bindings/detail_riwayat_hafalan_binding.dart';
import '../modules/ustadz/detail_riwayat_hafalan/views/detail_riwayat_hafalan_view.dart';
import '../modules/ustadz/detail_santri/bindings/detail_santri_binding.dart';
import '../modules/ustadz/detail_santri/views/detail_santri_view.dart';
import '../modules/ustadz/peringkat/bindings/peringkat_binding.dart';
import '../modules/ustadz/peringkat/views/peringkat_view.dart';
import '../modules/ustadz/progres_hafalan/bindings/progres_hafalan_binding.dart';
import '../modules/ustadz/progres_hafalan/views/progres_hafalan_view.dart';
import '../modules/ustadz/riwayat_hafalan/bindings/riwayat_hafalan_binding.dart';
import '../modules/ustadz/riwayat_hafalan/views/riwayat_hafalan_view.dart';
import '../modules/ustadz/summary_hafalan/bindings/summary_hafalan_binding.dart';
import '../modules/ustadz/summary_hafalan/views/summary_hafalan_view.dart';
import '../modules/ustadz/ustadz_home/bindings/ustadz_home_binding.dart';
import '../modules/ustadz/ustadz_home/views/ustadz_home_view.dart';
import '../modules/ustadz/ustadz_profile/bindings/ustadz_profile_binding.dart';
import '../modules/ustadz/ustadz_profile/views/ustadz_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
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
      middlewares: [AuthMiddleware()],
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
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.USTADZ_PROFILE,
      page: () => const UstadzProfileView(),
      binding: UstadzProfileBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ALQURAN,
      page: () => const AlquranView(),
      binding: AlquranBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.DETAIL_SANTRI,
      page: () => const DetailSantriView(),
      binding: DetailSantriBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.PROGRES_HAFALAN,
      page: () => const ProgresHafalanView(),
      binding: ProgresHafalanBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.USTADZ_MAIN,
      page: () => UstadzMainView(),
      binding: UstadzMainBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.SANTRI_MAIN,
      page: () => SantriMainView(),
      binding: SantriMainBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.ORTU_MAIN,
      page: () => OrtuMainView(),
      binding: OrtuMainBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: _Paths.RIWAYAT_HAFALAN,
      page: () => const RiwayatHafalanView(),
      binding: RiwayatHafalanBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_RIWAYAT_HAFALAN,
      page: () => const DetailRiwayatHafalanView(),
      binding: DetailRiwayatHafalanBinding(),
    ),
    GetPage(
      name: _Paths.PERINGKAT,
      page: () => const PeringkatView(),
      binding: PeringkatBinding(),
    ),
    GetPage(
      name: _Paths.SANTRI_PROFILE,
      page: () => const SantriProfileView(),
      binding: SantriProfileBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_PROGRES,
      page: () => const DetailProgresView(),
      binding: DetailProgresBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_SURAH,
      page: () => const DetailSurahView(),
      binding: DetailSurahBinding(),
    ),
    GetPage(
      name: _Paths.ORTU_PROFILE,
      page: () => const OrtuProfileView(),
      binding: OrtuProfileBinding(),
    ),
    GetPage(
      name: _Paths.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => const ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.SUMMARY_HAFALAN,
      page: () => const SummaryHafalanView(),
      binding: SummaryHafalanBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_ORTU,
      page: () => const DetailOrtuView(),
      binding: DetailOrtuBinding(),
    ),
    GetPage(
      name: _Paths.DOA_KHATAM,
      page: () => const DoaKhatamView(),
      binding: DoaKhatamBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN_HOME,
      page: () => const AdminHomeView(),
      binding: AdminHomeBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_SANTRI,
      page: () => const EditSantriView(),
      binding: EditSantriBinding(),
    ),
    GetPage(
      name: _Paths.TAMBAH_SANTRI,
      page: () => const TambahSantriView(),
      binding: TambahSantriBinding(),
    ),
    GetPage(
      name: _Paths.DAFTAR_ORTU,
      page: () => const DaftarOrtuView(),
      binding: DaftarOrtuBinding(),
    ),
    GetPage(
      name: _Paths.TAMBAH_ORTU,
      page: () => const TambahOrtuView(),
      binding: TambahOrtuBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_ORTU,
      page: () => const EditOrtuView(),
      binding: EditOrtuBinding(),
    ),
  ];
}
