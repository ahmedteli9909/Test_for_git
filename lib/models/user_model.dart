class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final DateTime createdAt;
  final bool isEmailVerified;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    required this.createdAt,
    this.isEmailVerified = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      isEmailVerified: json['is_email_verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
      'is_email_verified': isEmailVerified,
    };
  }
}



