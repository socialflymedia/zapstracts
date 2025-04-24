import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zapstract/features/Auth/presentation/screens/createAccount.dart';
import 'package:zapstract/features/onBoarding/presentation/screens/getStarted1.dart';
import 'package:zapstract/features/onBoarding/presentation/screens/onboarding.dart';
import 'package:zapstract/features/personalization/bloc/personalization_bloc.dart';
import 'package:zapstract/features/personalization/presentation/expertise_level_screen.dart';
import 'package:zapstract/features/personalization/presentation/goal_selection_screen.dart';


import 'Data/repositories/auth/auth_repository.dart';
import 'features/Auth/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hluyggttmzhhntscqaze.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
        '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhsdXln'
        'Z3R0bXpoaG50c2NxYXplIiwicm9sZSI6ImFub24iLC'
        'JpYXQiOjE3NDUyNTkwMzcsImV4cCI6MjA2MDgzNTAzN30.'
        'as9XS-_x7bDBs0rQr0nnTVI2hGaUppeyKongpGeShQU',
  );
  final AuthRepository authRepo = AuthRepository();
  runApp( MyApp(authRepo: authRepo));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepo;
  const MyApp({required this.authRepo, Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_ , child) {
        return MultiBlocProvider(
            providers: [
            BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(authRepo),
              child: CreateAccountScreen(),
        ),
              BlocProvider< PersonalizationBloc>(
                create: (_) => PersonalizationBloc(),
              ),
        // Add other blocs here if needed
        ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zapstract',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: child
          ),
        );
      },
child: OnBoardingScreen(),
    );
  }
}


