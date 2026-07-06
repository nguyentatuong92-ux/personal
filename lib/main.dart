import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'services/storage_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved theme
  final savedTheme = await StorageService.getThemeMode();
  if (savedTheme == 'dark') {
    themeNotifier.value = ThemeMode.dark;
  } else {
    themeNotifier.value = ThemeMode.light;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, mode, __) {
        return MaterialApp(
          title: 'Secure Password Manager',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF1E293B),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
              surface: const Color(0xFF334155),
              error: const Color(0xFFFF8A80),
            ),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              backgroundColor: Color(0xFF0F172A),
              foregroundColor: Colors.white,
            ),
            inputDecorationTheme: InputDecorationTheme(
              errorStyle: const TextStyle(color: Color(0xFFFF8A80)),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: Color(0xFFFF8A80)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(
                  color: Color(0xFFFF8A80),
                  width: 2,
                ),
              ),
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
