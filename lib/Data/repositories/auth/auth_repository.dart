import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final supabase = Supabase.instance.client;

  Stream<bool> get authChanges => supabase.auth.onAuthStateChange.map(
        (data) {
      final isLoggedIn = data.session?.user != null;
      print("Auth state changed. Logged in: $isLoggedIn");
      return isLoggedIn;
    },
  );

  Future<void> signUp(String email, String password, String name, String phone) async {
    print("Signing up user: $email");
    try {
      final res = await supabase.auth.signUp(email: email, password: password);
      final user = res.user;

      if (user == null) {
        print("Signup failed");
        throw Exception('Signup failed');
      }

      print("User signed up with ID: ${user.id}");

      final insertRes = await supabase.from('users').insert({
        'id': user.id,
        'email': email,
        'name': name,
        'phone': phone,
      }).select();

      print("Insert result: $insertRes");
      print("User data inserted successfully");
    } on AuthException catch (e) {
      print("AuthException during signup: ${e.message}");
      rethrow;
    } on PostgrestException catch (e) {
      print("PostgrestException during user insert: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error during signup: $e");
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    print("Logging in user: $email");
    try {
      final res = await supabase.auth.signInWithPassword(email: email, password: password);
      if (res.user == null) {
        print("Login failed");
        throw Exception('Login failed');
      }
      print("User logged in with ID: ${res.user!.id}");
    } on AuthException catch (e) {
      print("AuthException during login: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error during login: $e");
      rethrow;
    }
  }

  Future<void> logout() async {

    try {
      await supabase.auth.signOut();

    } on AuthException catch (e) {
      print("AuthException during logout: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error during logout: $e");
      rethrow;
    }
  }
}
