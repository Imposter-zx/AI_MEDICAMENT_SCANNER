import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('fr'),
  ];

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'AI Medicament Scanner',
      'scan': 'Scan',
      'docs': 'Docs',
      'imaging': 'Imaging',
      'trends': 'Trends',
      'search': 'Search',
      'settings': 'Settings',
      'aiAssistant': 'AI Assistant',
      'skip': 'Skip',
      'next': 'Next',
      'getStarted': 'Get Started',
      'retry': 'Retry',
      'error': 'Error',
      'loading': 'Loading...',
      'success': 'Success',
      'done': 'Done',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'share': 'Share',
      'export': 'Export Report',
      'medicationScanner': 'Medication Scanner',
      'documentAnalysis': 'Document Analysis',
      'medicalImaging': 'Medical Imaging',
      'results': 'Results',
      'profile': 'Profile',
      'chat': 'Chat',
      'pharmacy': 'Pharmacy',
      'markTaken': 'Mark Taken',
      'taken': 'Taken',
      'setReminder': 'Set Reminder',
      'findPharmacy': 'Find Pharmacy',
      'goodMorning': 'Good Morning',
      'goodAfternoon': 'Good Afternoon',
      'goodEvening': 'Good Evening',
      'chooseFeature': 'Choose a Feature',
      'familyProfiles': 'Family Health Profiles',
      'addNew': 'Add New',
      'safetyAlerts': 'Safety Alerts Detected',
      'activeMedications': 'Active Medications',
      'noActiveMedications': 'No active medications tracked. Scan your medicines to add reminders.',
      'recentAnalyses': 'Recent Analyses',
      'viewAll': 'View All',
      'safetyReminder': 'Safety Reminder',
      'appearance': 'Appearance',
      'notifications': 'Notifications',
      'dataPrivacy': 'Data & Privacy',
      'about': 'About',
      'systemDefault': 'System Default',
      'light': 'Light',
      'dark': 'Dark',
      'exportBackup': 'Export Backup',
      'importBackup': 'Import Backup',
      'clearAllData': 'Clear All Data',
      'usageAnalytics': 'Usage Analytics',
      'appVersion': 'App Version',
      'license': 'License',
      'privacyPolicy': 'Privacy Policy',
    },
    'ar': {
      'appTitle': 'ماسح الأدوية بالذكاء الاصطناعي',
      'scan': 'مسح',
      'docs': 'وثائق',
      'imaging': 'تصوير',
      'trends': 'اتجاهات',
      'search': 'بحث',
      'settings': 'الإعدادات',
      'aiAssistant': 'المساعد الذكي',
      'skip': 'تخطي',
      'next': 'التالي',
      'getStarted': 'ابدأ',
      'retry': 'إعادة المحاولة',
      'error': 'خطأ',
      'loading': 'جاري التحميل...',
      'success': 'نجاح',
      'done': 'تم',
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'delete': 'حذف',
      'share': 'مشاركة',
      'export': 'تصدير التقرير',
      'medicationScanner': 'ماسح الأدوية',
      'documentAnalysis': 'تحليل المستندات',
      'medicalImaging': 'التصوير الطبي',
      'results': 'النتائج',
      'profile': 'الملف الشخصي',
      'chat': 'محادثة',
      'pharmacy': 'صيدلية',
      'markTaken': 'وضع علامة تناول',
      'taken': 'تم التناول',
      'setReminder': 'تعيين تذكير',
      'findPharmacy': 'البحث عن صيدلية',
      'goodMorning': 'صباح الخير',
      'goodAfternoon': 'مساء الخير',
      'goodEvening': 'مساء الخير',
      'chooseFeature': 'اختر ميزة',
      'familyProfiles': 'الملفات الصحية العائلية',
      'addNew': 'إضافة جديد',
      'safetyAlerts': 'تم اكتشاف تنبيهات أمان',
      'activeMedications': 'الأدوية النشطة',
      'noActiveMedications': 'لا توجد أدوية نشطة يتم تتبعها. قم بمسح أدويتك لإضافتها.',
      'recentAnalyses': 'التحليلات الأخيرة',
      'viewAll': 'عرض الكل',
      'safetyReminder': 'تذكير بالسلامة',
      'appearance': 'المظهر',
      'notifications': 'الإشعارات',
      'dataPrivacy': 'البيانات والخصوصية',
      'about': 'حول',
      'systemDefault': 'إعداد النظام',
      'light': 'فاتح',
      'dark': 'داكن',
      'exportBackup': 'تصدير نسخة احتياطية',
      'importBackup': 'استيراد نسخة احتياطية',
      'clearAllData': 'مسح جميع البيانات',
      'usageAnalytics': 'تحليلات الاستخدام',
      'appVersion': 'إصدار التطبيق',
      'license': 'الترخيص',
      'privacyPolicy': 'سياسة الخصوصية',
    },
    'fr': {
      'appTitle': 'Scanner de Médicaments IA',
      'scan': 'Scanner',
      'docs': 'Documents',
      'imaging': 'Imagerie',
      'trends': 'Tendances',
      'search': 'Rechercher',
      'settings': 'Paramètres',
      'aiAssistant': 'Assistant IA',
      'skip': 'Passer',
      'next': 'Suivant',
      'getStarted': 'Commencer',
      'retry': 'Réessayer',
      'error': 'Erreur',
      'loading': 'Chargement...',
      'success': 'Succès',
      'done': 'Terminé',
      'save': 'Enregistrer',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'share': 'Partager',
      'export': 'Exporter le rapport',
      'medicationScanner': 'Scanner de Médicaments',
      'documentAnalysis': 'Analyse de Documents',
      'medicalImaging': 'Imagerie Médicale',
      'results': 'Résultats',
      'profile': 'Profil',
      'chat': 'Discussion',
      'pharmacy': 'Pharmacie',
      'markTaken': 'Marquer pris',
      'taken': 'Pris',
      'setReminder': 'Définir un rappel',
      'findPharmacy': 'Trouver une pharmacie',
      'goodMorning': 'Bonjour',
      'goodAfternoon': 'Bon après-midi',
      'goodEvening': 'Bonsoir',
      'chooseFeature': 'Choisir une fonction',
      'familyProfiles': 'Profils de santé familiaux',
      'addNew': 'Ajouter',
      'safetyAlerts': 'Alertes de sécurité détectées',
      'activeMedications': 'Médicaments actifs',
      'noActiveMedications': 'Aucun médicament actif suivi. Scannez vos médicaments pour les ajouter.',
      'recentAnalyses': 'Analyses récentes',
      'viewAll': 'Voir tout',
      'safetyReminder': 'Rappel de sécurité',
      'appearance': 'Apparence',
      'notifications': 'Notifications',
      'dataPrivacy': 'Données et confidentialité',
      'about': 'À propos',
      'systemDefault': 'Par défaut',
      'light': 'Clair',
      'dark': 'Sombre',
      'exportBackup': 'Exporter la sauvegarde',
      'importBackup': 'Importer la sauvegarde',
      'clearAllData': 'Effacer toutes les données',
      'usageAnalytics': 'Analyse d\'utilisation',
      'appVersion': 'Version de l\'app',
      'license': 'Licence',
      'privacyPolicy': 'Politique de confidentialité',
    },
  };

  String translate(String key) {
    final langMap = _localizedValues[locale.languageCode];
    return langMap?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String get appTitle => translate('appTitle');
  String get scan => translate('scan');
  String get docs => translate('docs');
  String get imaging => translate('imaging');
  String get trends => translate('trends');
  String get search => translate('search');
  String get settings => translate('settings');
  String get aiAssistant => translate('aiAssistant');
  String get skip => translate('skip');
  String get next => translate('next');
  String get getStarted => translate('getStarted');
  String get retry => translate('retry');
  String get error => translate('error');
  String get loading => translate('loading');
  String get success => translate('success');
  String get done => translate('done');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get share => translate('share');
  String get export => translate('export');
  String get medicationScanner => translate('medicationScanner');
  String get documentAnalysis => translate('documentAnalysis');
  String get medicalImaging => translate('medicalImaging');
  String get results => translate('results');
  String get profile => translate('profile');
  String get chat => translate('chat');
  String get pharmacy => translate('pharmacy');
  String get markTaken => translate('markTaken');
  String get taken => translate('taken');
  String get setReminder => translate('setReminder');
  String get findPharmacy => translate('findPharmacy');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
