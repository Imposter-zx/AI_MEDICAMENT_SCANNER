import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/medication_scan_screen.dart';
import 'screens/document_analysis_screen.dart';
import 'screens/medical_imaging_screen.dart';
import 'screens/results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'providers/medical_data_provider.dart';
import 'package:provider/provider.dart';
import 'providers/user_profile_provider.dart';
import 'providers/reminder_provider.dart';
import 'screens/profile_screen.dart';
import 'screens/trends_screen.dart';
import 'screens/medication_search_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/pharmacy_finder_screen.dart';
import 'l10n/app_localizations.dart';
import 'theme/app_theme.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final localeProvider = LocaleProvider();
    final themeProvider = ThemeProvider();

    await Future.wait([
      localeProvider.initialize(),
      themeProvider.initialize(),
    ]);

    AppLogger.info('App initialization successful');

    runApp(MyApp(initialLocale: localeProvider, initialTheme: themeProvider));
  } catch (e) {
    AppLogger.error('Failed to initialize app', e);
    runApp(
      MyApp(initialLocale: LocaleProvider(), initialTheme: ThemeProvider()),
    );
  }
}

class MyApp extends StatelessWidget {
  final LocaleProvider initialLocale;
  final ThemeProvider initialTheme;

  const MyApp({
    required this.initialLocale,
    required this.initialTheme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MedicalDataProvider()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider.value(value: initialLocale),
        ChangeNotifierProvider.value(value: initialTheme),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, _) {
          return FutureBuilder<bool>(
            future: _checkOnboarding(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return MaterialApp(
                  themeMode: themeProvider.themeMode,
                  theme: AppTheme.lightTheme(),
                  darkTheme: AppTheme.darkTheme(),
                  home: Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                );
              }

              return MaterialApp(
                locale: localeProvider.locale,
                title: 'AI Medicament Scanner',
                debugShowCheckedModeBanner: false,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: AppLocalizations.supportedLocales,
                themeMode: themeProvider.themeMode,
                theme: AppTheme.lightTheme(),
                darkTheme: AppTheme.darkTheme(),
                home: snapshot.data == true
                    ? const HomeScreen()
                    : const OnboardingScreen(),
                routes: {
                  '/medication-scan': (context) => const MedicationScanScreen(),
                  '/document-analysis': (context) =>
                      const DocumentAnalysisScreen(),
                  '/medical-imaging': (context) => const MedicalImagingScreen(),
                  '/results': (context) => const ResultsScreen(),
                  '/profile': (context) => const ProfileScreen(),
                  '/trends': (context) => const TrendsScreen(),
                  '/search': (context) => const MedicationSearchScreen(),
                  '/chat': (context) => const ChatScreen(),
                  '/settings': (context) => const SettingsScreen(),
                  '/pharmacy': (context) {
                    final args =
                        ModalRoute.of(context)?.settings.arguments as String?;
                    return PharmacyFinderScreen(medicationName: args);
                  },
                },
              );
            },
          );
        },
      ),
    );
  }

  static Future<bool> _checkOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('onboarding_complete') ?? false;
    } catch (e) {
      AppLogger.error('Failed to check onboarding status', e);
      return false;
    }
  }
}
