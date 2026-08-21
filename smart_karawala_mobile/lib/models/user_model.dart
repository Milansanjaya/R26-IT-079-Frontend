class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final bool isVerified;
  final String? phone;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.isVerified,
    this.phone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"] ?? json["_id"] ?? "",
      fullName: json["full_name"] ?? json["fullName"] ?? json["name"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "customer",
      isVerified: json["is_verified"] ?? json["isVerified"] ?? false,
      phone: json["phone"],
    );
  }
}