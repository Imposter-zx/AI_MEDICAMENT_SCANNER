import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_profile_provider.dart';
import '../providers/reminder_provider.dart';
import '../services/analytics_service.dart';
import '../services/backup_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _analyticsEnabled = false;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 0];
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _analyticsEnabled = prefs.getBool('analytics_enabled') ?? false;
      _selectedLanguage = prefs.getString('language') ?? 'en';
    });
  }

  Future<void> _saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    setState(() => _themeMode = mode);
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

  Future<void> _saveLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    setState(() => _selectedLanguage = lang);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('Appearance'),
          _buildThemeSelector(),
          const SizedBox(height: 8),
          _buildLanguageSelector(),
          const SizedBox(height: 24),
          _buildSectionTitle('Notifications'),
          _buildNotificationToggle(),
          const SizedBox(height: 24),
          _buildSectionTitle('Data & Privacy'),
          _buildDataSection(),
          const SizedBox(height: 24),
          _buildSectionTitle('Analytics'),
          _buildAnalyticsToggle(),
          if (_analyticsEnabled) ...[
            const SizedBox(height: 8),
            _buildAnalyticsSummary(),
          ],
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          _buildAboutSection(),
          const SizedBox(height: 40),
        ],
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

  Widget _buildThemeSelector() {
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
            groupValue: _themeMode,
            onChanged: (v) => _saveThemeMode(v!),
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
            groupValue: _themeMode,
            onChanged: (v) => _saveThemeMode(v!),
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
            groupValue: _themeMode,
            onChanged: (v) => _saveThemeMode(v!),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
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
            groupValue: _selectedLanguage,
            onChanged: (v) => _saveLanguage(v!),
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
            groupValue: _selectedLanguage,
            onChanged: (v) => _saveLanguage(v!),
          ),
          RadioListTile<String>(
            title: const Row(
              children: [
                Text('\u{1FEB}\u{1F1F7}'),
                SizedBox(width: 12),
                Text('Français (French)'),
              ],
            ),
            value: 'fr',
            groupValue: _selectedLanguage,
            onChanged: (v) => _saveLanguage(v!),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Medication Reminders'),
        subtitle: Text(
          _notificationsEnabled ? 'Notifications enabled' : 'Notifications disabled',
        ),
        secondary: Icon(
          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
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
                    const SnackBar(content: Text('Backup exported successfully!'), backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red),
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
                    content: Text(success ? 'Data imported successfully!' : 'Import failed or cancelled'),
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
      ],
    );
  }

  Widget _buildAnalyticsToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Usage Analytics'),
        subtitle: Text(
          _analyticsEnabled ? 'Tracking enabled (local only)' : 'Tracking disabled',
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
    final featureUsage = summary['featureUsage'] as Map<String, dynamic>? ?? {};
    if (featureUsage.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.grey),
              const SizedBox(width: 12),
              Expanded(child: Text('No usage data yet. Use the app to see analytics.', style: TextStyle(color: Colors.grey[600]))),
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
            const Text('Feature Usage', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...featureUsage.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            )),
            const SizedBox(height: 8),
            Text('Total events: ${summary['totalEvents']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
            leading: const Icon(Icons.description_outlined, color: Colors.green),
            title: const Text('License'),
            subtitle: const Text('MIT License'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.orange),
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
              if (mounted) {
                Navigator.pop(ctx);
                context.read<UserProfileProvider>().clearAll();
                context.read<ReminderProvider>().clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared'), backgroundColor: Colors.orange),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
