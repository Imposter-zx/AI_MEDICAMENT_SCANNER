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
import 'screens/profile_screen.dart';

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
      ],
      child: MaterialApp(
        title: 'AI Medical Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
        routes: {
          '/medication-scan': (context) => const MedicationScanScreen(),
          '/document-analysis': (context) => const DocumentAnalysisScreen(),
          '/medical-imaging': (context) => const MedicalImagingScreen(),
          '/results': (context) => const ResultsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}
