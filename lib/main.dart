import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'Data/repositories/auth/auth_repository.dart';
import 'features/Auth/bloc/auth_bloc.dart';
import 'features/Auth/presentation/screens/createAccount.dart';
import 'features/homeScreen/bloc/home_bloc.dart';
import 'features/homeScreen/home_screen.dart';
import 'features/onBoarding/presentation/screens/getStarted1.dart';
import 'features/onBoarding/presentation/screens/onboarding.dart';
import 'features/personalization/bloc/personalization_bloc.dart';
import 'features/personalization/presentation/expertise_level_screen.dart';
import 'features/personalization/presentation/goal_selection_screen.dart';
import 'features/profile/bloc/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://dnwqeyhibvxzxgtjhbes.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
        'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRud3FleWhp'
        'YnZ4enhndGpoYmVzIiwicm9sZSI6ImFub24iLCJpYXQiOj'
        'E3NDk3NDQ4ODMsImV4cCI6MjA2NTMyMDg4M30.zydjEwr1mgu'
        's_OH4fEk5GC4DUlcL6hNNs-5H2HRUqKA',
  );

  final authRepo = AuthRepository();
  runApp(MyApp(authRepo: authRepo));
}

Future<bool> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('login') ?? false;
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepo;
  const MyApp({required this.authRepo, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return FutureBuilder<bool>(
          future: checkLoginStatus(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                home: Scaffold(body: Center(child: CircularProgressIndicator())),
              );
            }

            final isLoggedIn = snapshot.data ?? false;

            return MultiBlocProvider(
              providers: [
                BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepo)),
                BlocProvider<PersonalizationBloc>(create: (_) => PersonalizationBloc()),
                BlocProvider<HomeBloc>(create: (_) => HomeBloc()),
                BlocProvider<ProfileBloc>(create: (_) => ProfileBloc()),
              ],
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Zapstract',
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                  textTheme: GoogleFonts.poppinsTextTheme(),
                ),
                home: isLoggedIn ? const HomeScreen() : const GetStarted(),
              ),
            );
          },
        );
      },
    );
  }
}
