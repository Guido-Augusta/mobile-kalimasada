// lib/app/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<String?> getCurrentRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<bool> isSantri() async {
    final role = await getCurrentRole();
    return role == 'santri';
  }

  static Future<bool> isUstadz() async {
    final role = await getCurrentRole();
    return role == 'ustadz';
  }

  static Future<bool> isOrtu() async {
    final role = await getCurrentRole();
    return role == 'ortu';
  }

  static Future<bool> isAdmin() async {
    final role = await getCurrentRole();
    return role == 'admin';
  }
}
