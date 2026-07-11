import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api.config.dart';
import '../models/chat_message.dart';

class ChatService {
  /// Mengambil daftar chat berdasarkan ID Proyek
  Future<List<ChatMessage>> getChats(String token, int projectId) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects/$projectId/chats'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Gagal memuat chat');
    }
  }

  /// Mengirim pesan chat ke AI
  Future<Map<String, dynamic>> sendMessage(String token, int projectId, String message) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/learning-projects/$projectId/chats'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'message': message,
      }),
    );

    if (response.statusCode == 201) {
      final jsonResponse = jsonDecode(response.body);
      final data = jsonResponse['data'];
      return {
        'messages': [
          ChatMessage.fromJson(data['user_message']),
          ChatMessage.fromJson(data['ai_message'])
        ],
        'reminder_action': jsonResponse['reminder_action'], // Bawa data pengingat ke atas
      };
    } else {
      throw Exception('Gagal mengirim pesan');
    }
  }
}
