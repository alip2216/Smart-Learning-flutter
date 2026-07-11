import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../data/services/auth_service.dart';
import '../data/models/user.dart';

class AuthProvider with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  final _authService = AuthService();
  
  bool _isLoading = false;
  String? _token;
  User? _user;

  bool get isLoading => _isLoading;
  String? get token => _token;
  bool get isAuthenticated => _token != null;
  User? get user => _user;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Memuat token dari secure storage saat aplikasi dimulai
  Future<void> loadToken() async {
    _token = await _storage.read(key: 'auth_token');
    if (_token != null) {
      await _fetchUser();
    }
    notifyListeners();
  }
  
  Future<void> _fetchUser() async {
    if (_token == null) return;
    try {
      final userData = await _authService.getUser(_token!);
      _user = User.fromJson(userData);
    } catch (e) {
      debugPrint("Gagal mengambil data user: $e");
      // Jika token tidak valid, hapus
      _token = null;
      _user = null;
      await _storage.delete(key: 'auth_token');
    }
  }

  /// Fungsi login yang memanggil AuthService
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final token = await _authService.login(email, password);
      
      if (token != null) {
        _token = token;
        await _storage.write(key: 'auth_token', value: _token!);
        await _fetchUser();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
    }
    _setLoading(false);
    return false;
  }

  /// Fungsi register yang memanggil AuthService
  Future<bool> register(String name, String email, String password, String passwordConfirmation) async {
    _setLoading(true);
    try {
      final token = await _authService.register(name, email, password, passwordConfirmation);
      
      if (token != null) {
        _token = token;
        await _storage.write(key: 'auth_token', value: _token!);
        await _fetchUser();
        _setLoading(false);
        return true;
      }
    } catch (e) {
      debugPrint("Register error: $e");
    }
    _setLoading(false);
    return false;
  }
  
  /// Fungsi untuk memperbarui profil
  Future<bool> updateProfile(String name, String email, {String? password, String? photoPath}) async {
    if (_token == null) return false;
    _setLoading(true);
    try {
      final userData = await _authService.updateProfile(
        _token!, 
        name, 
        email, 
        password: password, 
        photoPath: photoPath
      );
      _user = User.fromJson(userData);
      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint("Update profile error: $e");
      _setLoading(false);
      return false;
    }
  }

  /// Fungsi logout yang memanggil AuthService
  Future<void> logout() async {
    _setLoading(true);
    try {
      if (_token != null) {
        await _authService.logout(_token!);
      }
    } catch (e) {
      debugPrint("Logout error: $e");
    }
    
    _token = null;
    _user = null;
    await _storage.delete(key: 'auth_token');
    _setLoading(false);
    notifyListeners();
  }
}
