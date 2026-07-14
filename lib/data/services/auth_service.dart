import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api.config.dart';

class AuthService {
  /// Mengirim request login ke API
  /// Mengembalikan token (String) jika sukses, melempar Exception jika gagal.
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'] ?? data['access_token'];
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal login: ${response.statusCode}');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Gagal login: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  /// Mengirim request register ke API
  /// Mengembalikan token (String) jika sukses, melempar Exception jika gagal.
  Future<String?> register(String name, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/register'),
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['token'] ?? data['access_token'];
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal mendaftar: ${response.statusCode}');
      } catch (e) {
        if (e is FormatException) {
          throw Exception('Gagal mendaftar: ${response.statusCode}');
        }
        rethrow;
      }
    }
  }

  /// Mengirim request logout ke API
  Future<void> logout(String token) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/logout'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  /// Mengambil data user yang sedang login
  Future<Map<String, dynamic>> getUser(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil data user: ${response.statusCode}');
    }
  }

  /// Memperbarui profil (nama, email, password, foto)
  Future<Map<String, dynamic>> updateProfile(String token, String name, String email, {String? password, String? photoPath}) async {
    var request = http.MultipartRequest('POST', Uri.parse('${ApiConfig.baseUrl}/profile'));
    
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    });

    request.fields['name'] = name;
    request.fields['email'] = email;
    if (password != null && password.isNotEmpty) {
      request.fields['password'] = password;
    }

    if (photoPath != null) {
      request.files.add(await http.MultipartFile.fromPath('photo', photoPath));
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseBody)['data'];
    } else {
      throw Exception('Gagal memperbarui profil: ${response.statusCode}\n$responseBody');
    }
  }
}
