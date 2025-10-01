import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');

    // Jika tidak ada token, redirect ke login
    if (token == null) {
      return GetNavConfig.fromRoute('/login');
    }

    // Cek route yang memerlukan otorisasi khusus
    final currentRoute = route.uri;

    // Route yang hanya bisa diakses oleh ustadz
    const ustadzOnlyRoutes = [
      '/ustadz-home',
      '/ustadz-profile',
      '/daftar-santri',
      '/daftar-surah',
      '/detail-santri',
      '/progres-hafalan',
    ];

    // Route yang hanya bisa diakses oleh santri
    const santriOnlyRoutes = ['/santri-home'];

    // Route yang hanya bisa diakses oleh ortu
    const ortuOnlyRoutes = ['/ortu-home'];

    // Cek akses route khusus ustadz
    if (ustadzOnlyRoutes.contains(currentRoute.toString()) &&
        role != 'ustadz') {
      // Redirect ke home sesuai peran
      if (role == 'santri') {
        return GetNavConfig.fromRoute('/santri-home');
      } else if (role == 'ortu') {
        return GetNavConfig.fromRoute('/ortu-home');
      } else {
        return GetNavConfig.fromRoute('/home');
      }
    }

    // Cek akses route khusus santri
    if (santriOnlyRoutes.contains(currentRoute.toString()) &&
        role != 'santri') {
      // Redirect ke home sesuai peran
      if (role == 'ustadz') {
        return GetNavConfig.fromRoute('/ustadz-home');
      } else if (role == 'ortu') {
        return GetNavConfig.fromRoute('/ortu-home');
      } else {
        return GetNavConfig.fromRoute('/home');
      }
    }

    // Cek akses route khusus ortu
    if (ortuOnlyRoutes.contains(currentRoute.toString()) && role != 'ortu') {
      // Redirect ke home sesuai peran
      if (role == 'ustadz') {
        return GetNavConfig.fromRoute('/ustadz-home');
      } else if (role == 'santri') {
        return GetNavConfig.fromRoute('/santri-home');
      } else {
        return GetNavConfig.fromRoute('/home');
      }
    }

    // Lanjutkan ke route yang diminta
    return null;
  }
}
