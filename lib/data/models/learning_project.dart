class LearningProject {
  final int id;
  final String title;
  final String? description;
  final String status;
  final String createdAt;

  LearningProject({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory LearningProject.fromJson(Map<String, dynamic> json) {
    return LearningProject(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status'] ?? 'aktif',
      createdAt: json['created_at'] ?? '',
    );
  }
}
