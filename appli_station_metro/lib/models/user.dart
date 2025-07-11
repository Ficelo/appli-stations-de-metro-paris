class User {
  final int? id;
  String username;
  String language;

  User({this.id, required this.username, required this.language});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'language': language,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      language: map['language'],
    );
  }
}
