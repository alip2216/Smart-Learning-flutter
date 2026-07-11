class ChatMessage {
  final int id;
  final int learningProjectId;
  final String sender; // 'user' atau 'ai'
  final String message;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.learningProjectId,
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      learningProjectId: json['learning_project_id'],
      sender: json['sender'],
      message: json['message'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
