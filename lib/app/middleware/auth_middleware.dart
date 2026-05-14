import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../routes/app_pages.dart';

/// Middleware dasar untuk memastikan pengguna sudah login (Semua Role)
class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    return null;
  }
}

/// Middleware untuk rute khusus Ustadz & Admin
class UstadzMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    if (!AuthService.to.isUstadz && !AuthService.to.isAdmin) {
      return _getRedirectRouteBasedOnRole();
    }
    return null;
  }
}

/// Middleware untuk rute khusus Santri & Admin
class SantriMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    if (!AuthService.to.isSantri && !AuthService.to.isAdmin) {
      return _getRedirectRouteBasedOnRole();
    }
    return null;
  }
}

/// Middleware untuk rute khusus Ortu & Admin
class OrtuMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    if (!AuthService.to.isOrtu && !AuthService.to.isAdmin) {
      return _getRedirectRouteBasedOnRole();
    }
    return null;
  }
}

/// Middleware untuk rute yang bisa diakses Ustadz, Ortu, dan Admin
class UstadzOrtuMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    // Hanya izinkan jika Ustadz, Ortu, atau Admin
    if (!AuthService.to.isUstadz &&
        !AuthService.to.isOrtu &&
        !AuthService.to.isAdmin) {
      return _getRedirectRouteBasedOnRole();
    }
    return null;
  }
}

/// Middleware untuk rute khusus Admin
class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!AuthService.to.isLoggedIn) {
      return const RouteSettings(name: Routes.LOGIN);
    }
    if (!AuthService.to.isAdmin) {
      return _getRedirectRouteBasedOnRole();
    }
    return null;
  }
}

/// Middleware untuk halaman Login (mencegah ke login jika sudah login)
class GuestMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (AuthService.to.isLoggedIn) {
      return _getRedirectRouteBasedOnRole();
    }
    return null;
  }
}

/// Fungsi pembantu untuk mengarahkan ke home sesuai peran saat akses ditolak
RouteSettings _getRedirectRouteBasedOnRole() {
  if (AuthService.to.isUstadz) {
    return const RouteSettings(name: Routes.USTADZ_MAIN);
  } else if (AuthService.to.isSantri) {
    return const RouteSettings(name: Routes.SANTRI_MAIN);
  } else if (AuthService.to.isOrtu) {
    return const RouteSettings(name: Routes.ORTU_MAIN);
  } else if (AuthService.to.isAdmin) {
    return const RouteSettings(name: Routes.ADMIN_HOME);
  } else {
    return const RouteSettings(name: Routes.LOGIN);
  }
}
