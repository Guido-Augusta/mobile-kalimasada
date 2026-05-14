// lib/app/services/auth_service.dart
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole { santri, ustadz, ortu, admin, unknown }

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  late SharedPreferences _prefs;

  final RxString token = ''.obs;
  final RxString userId = ''.obs;
  final RxString roleId = ''.obs;
  final Rx<UserRole> currentRole = UserRole.unknown.obs;

  Future<AuthService> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
    return this;
  }

  void _loadFromPrefs() {
    token.value = _prefs.getString('token') ?? '';
    userId.value = _prefs.getString('userId') ?? '';
    roleId.value = _prefs.getString('roleId') ?? '';

    final roleStr = _prefs.getString('role');
    switch (roleStr) {
      case 'santri':
        currentRole.value = UserRole.santri;
        break;
      case 'ustadz':
        currentRole.value = UserRole.ustadz;
        break;
      case 'ortu':
        currentRole.value = UserRole.ortu;
        break;
      case 'admin':
        currentRole.value = UserRole.admin;
        break;
      default:
        currentRole.value = UserRole.unknown;
    }
  }

  // Synchronous Checks
  bool get isSantri => currentRole.value == UserRole.santri;
  bool get isUstadz => currentRole.value == UserRole.ustadz;
  bool get isOrtu => currentRole.value == UserRole.ortu;
  bool get isAdmin => currentRole.value == UserRole.admin;
  bool get isLoggedIn => token.value.isNotEmpty;
  
  // Return string value of role manually if needed
  String get roleString {
    switch (currentRole.value) {
      case UserRole.santri: return 'santri';
      case UserRole.ustadz: return 'ustadz';
      case UserRole.ortu: return 'ortu';
      case UserRole.admin: return 'admin';
      default: return '';
    }
  }

  Future<void> login({
    required String newToken,
    required String newRole,
    required String newUserId,
    required String newRoleId,
  }) async {
    await _prefs.setString('token', newToken);
    await _prefs.setString('role', newRole);
    await _prefs.setString('userId', newUserId);
    await _prefs.setString('roleId', newRoleId);

    _loadFromPrefs();
  }

  Future<void> logout() async {
    await _prefs.remove('token');
    await _prefs.remove('role');
    await _prefs.remove('userId');
    await _prefs.remove('roleId');

    _loadFromPrefs();
  }
}
