import 'package:flutter/material.dart';
import 'package:fundit/pages/homescreen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fundit/theme/theme_controller.dart';

final ThemeController themeController = ThemeController();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeController.loadTheme();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController.themeNotifier,
      builder: (_, ThemeMode mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fundit',
          themeMode: mode,

          // 🌞 LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            textTheme: GoogleFonts.interTextTheme().copyWith(
              headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
              titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            useMaterial3: true,
          ),

          // 🌙 DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
                .copyWith(
                  headlineSmall: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
            useMaterial3: true,
          ),

          home: Homescreen(themeController: themeController),
        );
      },
    );
  }
}
