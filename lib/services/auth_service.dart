// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyLoggedIn = 'is_logged_in';
  static const String _keyCurrentUser = 'current_user';

  /// Register akun baru
  static Future<String?> register({
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    if (username.trim().isEmpty) return 'Username tidak boleh kosong';
    if (username.trim().length < 3) return 'Username minimal 3 karakter';
    if (password.length < 6) return 'Password minimal 6 karakter';
    if (password != confirmPassword) return 'Password tidak cocok';

    final prefs = await SharedPreferences.getInstance();

    // Cek apakah username sudah dipakai
    final existingUsers = prefs.getStringList('all_users') ?? [];
    if (existingUsers.contains(username.trim())) {
      return 'Username sudah digunakan';
    }

    // Simpan user baru
    existingUsers.add(username.trim());
    await prefs.setStringList('all_users', existingUsers);
    await prefs.setString('user_pwd_${username.trim()}', password);

    return null; // null = sukses
  }

  /// Login
  static Future<String?> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty) return 'Username tidak boleh kosong';
    if (password.isEmpty) return 'Password tidak boleh kosong';

    final prefs = await SharedPreferences.getInstance();
    final savedPassword = prefs.getString('user_pwd_${username.trim()}');

    if (savedPassword == null) return 'Akun tidak ditemukan';
    if (savedPassword != password) return 'Password salah';

    // Simpan sesi
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setString(_keyCurrentUser, username.trim());

    return null; // null = sukses
  }

  /// Logout - hapus sesi
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoggedIn);
    await prefs.remove(_keyCurrentUser);
  }

  /// Cek apakah sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  /// Ambil username yang sedang login
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCurrentUser);
  }
}
