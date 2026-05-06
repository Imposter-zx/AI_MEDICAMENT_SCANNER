import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_profile_provider.dart';
import '../services/openai_chat_service.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/reminder_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/backup_service.dart';
import '../services/ai_cache_service.dart';
import '../widgets/premium_background.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = false;
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _placesApiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadApiKey();
    _loadPlacesApiKey();
  }

  Future<void> _loadApiKey() async {
    final key = await OpenAIChatService().getApiKey();
    setState(() {
      _apiKeyController.text = key ?? '';
    });
  }

  Future<void> _saveApiKey() async {
    final key = _apiKeyController.text.trim();
    if (key.isNotEmpty) {
      await OpenAIChatService().setApiKey(key);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('OpenAI API Key saved')));
      }
    }
  }

  Future<void> _loadPlacesApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _placesApiKeyController.text = prefs.getString('places_api_key') ?? '';
    });
  }

  Future<void> _savePlacesApiKey() async {
    final key = _placesApiKeyController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('places_api_key', key);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Places API Key saved')));
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? false;
    });
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _saveAnalytics(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('analytics_enabled', value);
    await AnalyticsService().setEnabled(value);
    setState(() => _analyticsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          children: [
            _buildSectionTitle(AppLocalizations.of(context).appearance),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) =>
                  _buildThemeSelector(themeProvider),
            ),
          const SizedBox(height: 8),
          Consumer<LocaleProvider>(
            builder: (context, localeProvider, _) =>
                _buildLanguageSelector(localeProvider),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context).notifications),
          _buildNotificationToggle(),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context).dataPrivacy),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context).usageAnalytics),
          _buildAnalyticsToggle(),
          if (_analyticsEnabled) ...[
            const SizedBox(height: 8),
            _buildAnalyticsSummary(),
          ],
          // Places API Key for real pharmacy search
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('placesApiKey'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _placesApiKeyController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      ).translate('placesApiKeyPlaceholder'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _savePlacesApiKey,
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).translate('savePlacesApiKey'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // OpenAI API Key management
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('openaiApiKey'),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(
                        context,
                      ).translate('openaiApiKeyPlaceholder'),
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _saveApiKey,
                      child: Text(
                        AppLocalizations.of(context).translate('saveApiKey'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context).about),
          _buildAboutSection(),
          const SizedBox(height: 40),
        ],
      ),
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    return Card(
      child: Column(
        children: [
          RadioListTile<ThemeMode>(
            title: const Row(
              children: [
                Icon(Icons.brightness_auto),
                SizedBox(width: 12),
                Text('System Default'),
              ],
            ),
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (v) => themeProvider.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Row(
              children: [
                Icon(Icons.light_mode),
                SizedBox(width: 12),
                Text('Light'),
              ],
            ),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (v) => themeProvider.setThemeMode(v!),
          ),
          RadioListTile<ThemeMode>(
            title: const Row(
              children: [
                Icon(Icons.dark_mode),
                SizedBox(width: 12),
                Text('Dark'),
              ],
            ),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (v) => themeProvider.setThemeMode(v!),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(LocaleProvider localeProvider) {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            title: const Row(
              children: [
                Text('\u{1F1EC}\u{1F1E7}'),
                SizedBox(width: 12),
                Text('English'),
              ],
            ),
            value: 'en',
            groupValue: localeProvider.locale.languageCode,
            onChanged: (v) => localeProvider.setLanguageCode(v!),
          ),
          RadioListTile<String>(
            title: const Row(
              children: [
                Text('\u{1F1F8}\u{1F1E6}'),
                SizedBox(width: 12),
                Text('العربية (Arabic)'),
              ],
            ),
            value: 'ar',
            groupValue: localeProvider.locale.languageCode,
            onChanged: (v) => localeProvider.setLanguageCode(v!),
          ),
          RadioListTile<String>(
            title: const Row(
              children: [
                Text('\u{1F1EB}\u{1F1F7}'),
                SizedBox(width: 12),
                Text('Français (French)'),
              ],
            ),
            value: 'fr',
            groupValue: localeProvider.locale.languageCode,
            onChanged: (v) => localeProvider.setLanguageCode(v!),
          ),
          RadioListTile<String>(
            title: const Row(
              children: [
                Text('\u{1F1EA}\u{1F1F8}'),
                SizedBox(width: 12),
                Text('Español (Spanish)'),
              ],
            ),
            value: 'es',
            groupValue: localeProvider.locale.languageCode,
            onChanged: (v) => localeProvider.setLanguageCode(v!),
          ),
          RadioListTile<String>(
            title: const Row(
              children: [
                Text('\u{1F1E9}\u{1F1EA}'),
                SizedBox(width: 12),
                Text('Deutsch (German)'),
              ],
            ),
            value: 'de',
            groupValue: localeProvider.locale.languageCode,
            onChanged: (v) => localeProvider.setLanguageCode(v!),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: SwitchListTile(
        title: Text(l10n.medicationReminders),
        subtitle: Text(
          _notificationsEnabled
              ? l10n.notificationsEnabled
              : l10n.notificationsDisabled,
        ),
        secondary: Icon(
          _notificationsEnabled
              ? Icons.notifications_active
              : Icons.notifications_off,
          color: _notificationsEnabled ? Colors.blue : Colors.grey,
        ),
        value: _notificationsEnabled,
        onChanged: _saveNotifications,
      ),
    );
  }

  Widget _buildDataSection() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.backup_outlined, color: Colors.blue),
            title: const Text('Export Backup'),
            subtitle: const Text('Save all your data to a file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              try {
                await BackupService().exportAndShare();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup exported successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Export failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.restore_outlined, color: Colors.green),
            title: const Text('Import Backup'),
            subtitle: const Text('Restore data from a backup file'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final success = await BackupService().importFromFile();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Data imported successfully!'
                          : 'Import failed or cancelled',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
                if (success) {
                  context.read<UserProfileProvider>().loadProfiles();
                  context.read<ReminderProvider>().init();
                }
              }
            },
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all profiles, reminders, and history'),
            onTap: () => _showClearDataDialog(),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.memory, color: Colors.blue),
            title: const Text('Clear AI Cache'),
            subtitle: const Text('Remove cached AI responses to save space'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await AICacheService().clearCache();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('AI Cache cleared successfully!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Usage Analytics'),
        subtitle: Text(
          _analyticsEnabled
              ? 'Tracking enabled (local only)'
              : 'Tracking disabled',
        ),
        secondary: Icon(
          _analyticsEnabled ? Icons.analytics : Icons.analytics_outlined,
          color: _analyticsEnabled ? Colors.purple : Colors.grey,
        ),
        value: _analyticsEnabled,
        onChanged: _saveAnalytics,
      ),
    );
  }

  Widget _buildAnalyticsSummary() {
    final summary = AnalyticsService().getUsageSummary();
    final featureUsage = (summary['featureUsage'] as Map? ?? {});
    if (featureUsage.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No usage data yet. Use the app to see analytics.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feature Usage',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...featureUsage.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text(
                      '${e.value}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Total events: ${summary['totalEvents']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: Colors.green,
            ),
            title: const Text('License'),
            subtitle: const Text('MIT License'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(
              Icons.privacy_tip_outlined,
              color: Colors.orange,
            ),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Your data stays on your device'),
          ),
        ),
      ],
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your profiles, reminders, and analysis history. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await BackupService().clearAllData();
              if (!context.mounted) return;
              Navigator.pop(ctx);
                context.read<UserProfileProvider>().clearAll();
                context.read<ReminderProvider>().clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data cleared'),
                    backgroundColor: Colors.orange,
                  ),
                );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
