class AuthUser {
  const AuthUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.role,
    required this.token,
  });

  final int userId;
  final String username;
  final String email;
  final String role;
  final String token;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      return int.tryParse('$value') ?? 0;
    }

    return AuthUser(
      userId: parseInt(json['userId'] ?? json['UserId'] ?? json['id'] ?? json['Id']),
      username: (json['username'] ?? json['Username'] ?? '').toString(),
      email: (json['email'] ?? json['Email'] ?? '').toString(),
      role: (json['role'] ?? json['Role'] ?? '').toString(),
      token: (json['token'] ?? json['Token'] ?? '').toString(),
    );
  }
}
