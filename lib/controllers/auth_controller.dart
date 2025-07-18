import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  // Register new user
  Future<UserModel?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.createUser(email, password);
      if (user != null) {
        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          photoUrl: '',
          isOnline: true,
          lastSeen: DateTime.now().toIso8601String(),
        );
        await _authService.saveUserToFirestore(userModel);
        return userModel;
      }
    } catch (e) {
      print("Register Error: $e");
    }
    return null;
  }

  // Login user
  Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _authService.signIn(email, password);
      if (user != null) {
        return await _authService.getUserById(user.uid);
      }
    } catch (e) {
      print("Login Error: $e");
    }
    return null;
  }

  // Logout user
  Future<void> logout() async {
    await _authService.signOut();
  }

  // Update online/offline status
  Future<void> updateOnlineStatus(bool isOnline) async {
    await _authService.updateUserStatus(isOnline);
  }
}
