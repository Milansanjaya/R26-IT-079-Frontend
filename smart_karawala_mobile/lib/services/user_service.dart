import 'api_service.dart';
import 'storage_service.dart';

class UserService {
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception("Authentication token not found.");
    }
    return await ApiService.get("/auth/me", token);
  }
}
