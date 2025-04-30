import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recetapp/firebase_options.dart';
import 'package:recetapp/screens/login_screen.dart';

import 'screens/main_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final ColorScheme lightColorScheme =
            lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue);
        final ColorScheme darkColorScheme = ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          title: 'Recetapp',
          theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          home: StreamBuilder<firebase_auth.User?>(
            stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasData) {
                return const MainHomeScreen();
              }
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
