class LearningLog {
  final int id;
  final int learningProjectId;
  final String note;
  final String progressDate;
  final String createdAt;

  LearningLog({
    required this.id,
    required this.learningProjectId,
    required this.note,
    required this.progressDate,
    required this.createdAt,
  });

  factory LearningLog.fromJson(Map<String, dynamic> json) {
    return LearningLog(
      id: json['id'],
      learningProjectId: json['learning_project_id'],
      note: json['note'],
      progressDate: json['progress_date'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
