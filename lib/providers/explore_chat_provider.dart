import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../api.config.dart';

class ExploreChatMessage {
  final String sender; // 'user' atau 'ai'
  final String text;
  
  ExploreChatMessage({required this.sender, required this.text});
}

class ExploreChatProvider with ChangeNotifier {
  final List<ExploreChatMessage> _messages = [];
  bool _isLoading = false;
  
  late final GenerativeModel _model;
  late final ChatSession _chat;

  ExploreChatProvider() {
    _initGemini();
  }

  List<ExploreChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void _initGemini() {
    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite',
      apiKey: ApiConfig.geminiApiKey,
      systemInstruction: Content.system('Nama kamu adalah Anwar, asisten AI cerdas dan ramah. Kamu adalah hasil ide brilian dan diciptakan oleh seorang mahasiswa bernama Alif. Jika ditanya tentang penciptamu atau asal-usulmu, ceritakan dengan bangga bahwa kamu adalah karya dari Alif. Jawab semua pertanyaan pengguna dengan asik, informatif, dan menggunakan bahasa Indonesia yang santai. Jangan lupa gunakan format Markdown agar rapi.'),
    );
    _chat = _model.startChat();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Tambah pesan user ke UI
    _messages.add(ExploreChatMessage(sender: 'user', text: text));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      if (response.text != null) {
        _messages.add(ExploreChatMessage(sender: 'ai', text: response.text!));
      } else {
        _messages.add(ExploreChatMessage(sender: 'ai', text: 'Maaf, saya tidak mengerti.'));
      }
    } catch (e) {
      debugPrint('Explore Gemini Error: $e');
      _messages.add(ExploreChatMessage(
        sender: 'ai', 
        text: 'Maaf, terjadi kesalahan:\n\n`$e`\n\n(Mohon periksa kembali API Key atau koneksi internet Anda.)'
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
