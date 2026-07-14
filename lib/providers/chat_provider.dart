import 'package:flutter/material.dart';
import '../data/models/chat_message.dart';
import '../data/services/chat_service.dart';
import '../utils/notification_service.dart';

class ChatProvider with ChangeNotifier {
  final _chatService = ChatService();
  
  List<ChatMessage> _chats = [];
  bool _isLoading = false;
  bool _isSending = false;

  List<ChatMessage> get chats => _chats;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;

  Future<void> loadChats(String token, int projectId) async {
    _chats = []; // Bersihkan state lama agar tidak bocor antar proyek
    _isLoading = true;
    notifyListeners();

    try {
      final fetchedChats = await _chatService.getChats(token, projectId);
      _chats = fetchedChats.map(_interceptErrorMessage).toList();
    } catch (e) {
      debugPrint("Load chats error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String token, int projectId, String message) async {
    _isSending = true;
    notifyListeners();

    try {
      final response = await _chatService.sendMessage(token, projectId, message);
      final newMessages = response['messages'] as List<ChatMessage>;
      
      final mappedMessages = newMessages.map(_interceptErrorMessage).toList();
      _chats.addAll(mappedMessages);

      // Cek apakah ada aksi pengingat (Tahap 3)
      if (response['reminder_action'] != null) {
        final reminderData = response['reminder_action'];
        try {
          final timeStr = reminderData['time'];
          final msg = reminderData['message'];
          final scheduledTime = DateTime.parse(timeStr);

          // Panggil NotificationService
          await NotificationService().scheduleNotification(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            title: 'Anwar - Smart Learning',
            body: msg,
            scheduledTime: scheduledTime,
          );
        } catch (e) {
          debugPrint('Error parsing reminder time: $e');
        }
      }

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Send message error: $e");
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  ChatMessage _interceptErrorMessage(ChatMessage msg) {
    if (msg.sender == 'ai' && msg.message.toLowerCase().contains('terjadi kesalahan saat menghubungi server ai')) {
      return ChatMessage(
        id: msg.id,
        learningProjectId: msg.learningProjectId,
        sender: msg.sender,
        message: 'Jika Anda ingin bertanya di luar pertanyaan mengenai project, bisa langsung temui Anwar di tab Explore yaa!',
        createdAt: msg.createdAt,
      );
    }
    return msg;
  }
}
