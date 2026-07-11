class User {
  final int id;
  final String name;
  final String email;
  final String? profilePhotoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profilePhotoUrl: json['photo_url'] ?? json['profile_photo_path'],
    );
  }
}
