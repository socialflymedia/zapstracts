import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
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




      // ✅ Store locally after checking/inserting user
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id);
      await prefs.setString('email', email);
      await prefs.setString('name', name);
      await prefs.setString('phone', phone);
    //  await prefs.setString('image', image);
      await prefs.setBool('login', true);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('email');
      await prefs.remove('name');
      await prefs.remove('phone');
      await prefs.remove('image');
      await prefs.remove('login');

      await supabase.auth.signOut();
    } on AuthException catch (e) {
      print("AuthException during logout: ${e.message}");
      rethrow;
    } catch (e) {
      print("Unexpected error during logout: $e");
      rethrow;
    }
  }
  Future<bool> signUpWithGoogle() async {
    bool newUser = false;
    const webClientId = 'my-web.apps.googleusercontent.com';
    const iosClientId = 'my-ios.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: '401107895655-3o0kq37c5gl2vm5t8tjvtl3hsjvcadgs.apps.googleusercontent.com',
      serverClientId: '401107895655-oo3h4s40h1gqrv1rp3v2greukfcgk7u7.apps.googleusercontent.com',
    );

    await googleSignIn.signOut(); // To ensure fresh login
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw 'Google sign-in aborted';

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) throw 'No Access Token found.';
    if (idToken == null) throw 'No ID Token found.';

    final authResponse = await supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    final user = authResponse.user;
    if (user == null) throw 'User not returned after sign-in.';

    final name = user.userMetadata?['name'] ?? '';
    final email = user.email ?? '';
    final image = user.userMetadata?['avatar_url'] ?? '';
    final phone = user.phone ?? '';

    // ✅ Check if user already exists
    final userExists = await supabase
        .from('users')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (userExists == null) {
      // First-time sign-up → Insert user
      await supabase.from('users').insert({
        'id': user.id,
        'email': email,
        'name': name,
        'phone': phone
      });
      print('✅ New user inserted in Supabase');
      newUser = true;
    } else {
      print('👤 User already exists, skipping insert');
      newUser = false;
    }

    // ✅ Store locally after checking/inserting user
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', user.id);
    await prefs.setString('email', email);
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setString('image', image);
    await prefs.setBool('login', true);

    print('✅ User signed in and data stored locally');

    return newUser; // true → new user, false → already existed
  }


  // Future<void> signUpWithGoogle() async {
  //
  //   // client secret = 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
  //   const webClientId = 'my-web.apps.googleusercontent.com';
  //   /// TODO: update the iOS client ID with your own.
  //   ///
  //   /// iOS Client ID that you registered with Google Cloud.
  //   const iosClientId = 'my-ios.apps.googleusercontent.com';
  //   final GoogleSignIn googleSignIn = GoogleSignIn(
  //     clientId: '401107895655-3o0kq37c5gl2vm5t8tjvtl3hsjvcadgs.apps.googleusercontent.com',
  //     serverClientId: '401107895655-oo3h4s40h1gqrv1rp3v2greukfcgk7u7.apps.googleusercontent.com',
  //   );
  //   final googleUser = await googleSignIn.signIn();
  //   final googleAuth = await googleUser!.authentication;
  //   final accessToken = googleAuth.accessToken;
  //   final idToken = googleAuth.idToken;
  //   if (accessToken == null) {
  //     throw 'No Access Token found.';
  //   }
  //   if (idToken == null) {
  //     throw 'No ID Token found.';
  //   }
  //   await supabase.auth.signInWithIdToken(
  //     provider: OAuthProvider.google,
  //     idToken: idToken,
  //     accessToken: accessToken,
  //   );
  //
  //   final insertRes = await supabase.from('users').insert({
  //     'id': user.id,
  //     'email': email,
  //     'name': name,
  //     'phone': phone,
  //   }).select();
  // }
}
