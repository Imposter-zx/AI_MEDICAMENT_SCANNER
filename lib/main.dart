import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/medication_scan_screen.dart';
import 'screens/document_analysis_screen.dart';
import 'screens/medical_imaging_screen.dart';
import 'screens/results_screen.dart';
import 'providers/medical_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/user_profile_provider.dart';
import 'providers/reminder_provider.dart';
import 'screens/profile_screen.dart';
import 'screens/trends_screen.dart';
import 'screens/medication_search_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/pharmacy_finder_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicalDataProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: MaterialApp(
        title: 'AI Medical Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E3A8A), // Deep Blue
            primary: const Color(0xFF2563EB),
            secondary: const Color(0xFF0D9488), // Teal
            surface: const Color(0xFFF8FAFC),
            background: const Color(0xFFF1F5F9),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.plusJakartaSansTextTheme().apply(
            bodyColor: const Color(0xFF0F172A),
            displayColor: const Color(0xFF0F172A),
          ),
          cardTheme: CardTheme(
            elevation: 8,
            shadowColor: const Color(0xFF2563EB).withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            clipBehavior: Clip.antiAlias,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
            ),
          ),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF3B82F6),
            primary: const Color(0xFF3B82F6),
            secondary: const Color(0xFF14B8A6),
            surface: const Color(0xFF1E293B),
            background: const Color(0xFF0F172A),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme).apply(
            bodyColor: const Color(0xFFF8FAFC),
            displayColor: const Color(0xFFF8FAFC),
          ),
          cardTheme: CardTheme(
            elevation: 8,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            clipBehavior: Clip.antiAlias,
            color: const Color(0xFF1E293B),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1E293B),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        routes: {
          '/medication-scan': (context) => const MedicationScanScreen(),
          '/document-analysis': (context) => const DocumentAnalysisScreen(),
          '/medical-imaging': (context) => const MedicalImagingScreen(),
          '/results': (context) => const ResultsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/trends': (context) => const TrendsScreen(),
          '/search': (context) => const MedicationSearchScreen(),
          '/chat': (context) => const ChatScreen(),
          '/pharmacy': (context) {
            final args = ModalRoute.of(context)?.settings.arguments as String?;
            return PharmacyFinderScreen(medicationName: args);
          },
        },
      ),
    );
  }
}
