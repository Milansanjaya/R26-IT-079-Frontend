class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isVerified;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json["id"] ?? json["_id"] ?? "").toString(),
      fullName: (json["full_name"] ?? json["fullName"] ?? json["name"] ?? json["username"] ?? "").toString(),
      email: (json["email"] ?? json["username"] ?? "").toString(),
      role: (json["role"] ?? "admin").toString().toLowerCase(),
      isVerified: json["is_verified"] ?? json["isVerified"] ?? true,
    );
  }
}