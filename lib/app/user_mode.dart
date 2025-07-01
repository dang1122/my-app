class User {
  final String id;
  final String username;
  final String password;

  User({required this.id, required this.username, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'username': username, 'password': password};
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username)';
  }
}
