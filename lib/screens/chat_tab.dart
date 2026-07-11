import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../data/models/learning_project.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';

class ChatTab extends StatefulWidget {
  final LearningProject project;

  const ChatTab({super.key, required this.project});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchChats();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchChats() {
    final token = context.read<AuthProvider>().token;
    if (token != null) {
      context.read<ChatProvider>().loadChats(token, widget.project.id);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    _messageController.clear();
    
    // Auto scroll setelah mengirim
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    final chatProvider = context.read<ChatProvider>();
    await chatProvider.sendMessage(token, widget.project.id, text);
    
    // Auto scroll setelah menerima balasan AI
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat Area
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading && provider.chats.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
              }

              if (provider.chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.smart_toy_rounded, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text(
                        'Mulai Obrolan',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Kirim pesan untuk berdiskusi dengan Anwar!',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: provider.chats.length,
                itemBuilder: (context, index) {
                  final chat = provider.chats[index];
                  final isUser = chat.sender == 'user';

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF4F46E5) : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
                          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: isUser
                          ? Text(
                              chat.message,
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            )
                          : MarkdownBody(
                              data: chat.message,
                              styleSheet: MarkdownStyleSheet(
                                p: const TextStyle(color: Color(0xFF111827), fontSize: 15),
                                h1: const TextStyle(color: Color(0xFF111827)),
                                h2: const TextStyle(color: Color(0xFF111827)),
                                h3: const TextStyle(color: Color(0xFF111827)),
                                listBullet: const TextStyle(color: Color(0xFF4F46E5)),
                              ),
                            ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Indikator AI Sedang Mengetik
        Consumer<ChatProvider>(
          builder: (context, provider, child) {
            if (provider.isSending) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF4F46E5)),
                    ),
                    const SizedBox(width: 8),
                    Text('Anwar sedang mengetik...', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Input Area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tanya sesuatu tentang proyek ini...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                Consumer<ChatProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: provider.isSending ? null : _sendMessage,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
