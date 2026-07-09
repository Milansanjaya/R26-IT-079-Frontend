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
      id: json["id"] ?? json["_id"] ?? "",
      fullName: json["full_name"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "customer",
      isVerified: json["is_verified"] ?? false,
    );
  }
}