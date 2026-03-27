import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../providers/medical_data_provider.dart';
import '../providers/user_profile_provider.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController _confettiController;
  bool _hasCelebratedToday = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkAndCelebrate(List<MedicationReminder> reminders) {
    if (reminders.isEmpty) return;
    
    final activeReminders = reminders.where((r) => r.isActive).toList();
    if (activeReminders.isEmpty) return;

    final now = DateTime.now();
    final allTakenToday = activeReminders.every((r) {
      if (r.lastTaken == null) return false;
      return r.lastTaken!.year == now.year && 
             r.lastTaken!.month == now.month && 
             r.lastTaken!.day == now.day;
    });

    if (allTakenToday && !_hasCelebratedToday) {
      _confettiController.play();
      setState(() {
        _hasCelebratedToday = true;
      });
    } else if (!allTakenToday) {
      _hasCelebratedToday = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Medical Assistant'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 24),
                  const Text(
                    'Choose a Feature',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSmallFeatureCard(context, 'assets/icons/medication_icon.png', 'Scan', '/medication-scan')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSmallFeatureCard(context, 'assets/icons/document_scanner_icon.png', 'Docs', '/document-analysis')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildSmallFeatureCard(context, 'assets/icons/medical_imaging_icon.png', 'Imaging', '/medical-imaging')),
                      const SizedBox(width: 8),
                      Expanded(child: _buildActionCard(context, Icons.analytics_outlined, 'Trends', '/trends', Colors.orange)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildActionCard(context, Icons.manage_search, 'Search', '/search', Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildMedicationDashboard(context),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Analyses',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const HistoryList(),
                  const SizedBox(height: 32),
                  _buildSafetyNotice(),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;
        final name = profile?.name ?? "Guest";
        final hour = DateTime.now().hour;
        String greetingPrefix = "Good Morning";
        if (hour >= 12 && hour < 17) greetingPrefix = "Good Afternoon";
        if (hour >= 17) greetingPrefix = "Good Evening";

        return Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: const DecorationImage(
              image: AssetImage('assets/images/medical_home_banner.png'),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$greetingPrefix,\n$name',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      profile != null ? Icons.verified_user : Icons.help_outline,
                      color: profile != null ? Colors.greenAccent : Colors.orangeAccent,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      profile != null ? 'Health Profile Active' : 'Set up your health profile',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.9), letterSpacing: 0.5),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String title, String route, Color color) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallFeatureCard(BuildContext context, String assetPath, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Image.asset(assetPath, height: 28, width: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationDashboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Active Medications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<ReminderProvider>(
          builder: (context, provider, _) {
            // Trigger celebration check
            WidgetsBinding.instance.addPostFrameCallback((_) => _checkAndCelebrate(provider.reminders));
            
            final activeReminders = provider.reminders.where((r) => r.isActive).toList();
            if (activeReminders.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(child: Text('No active medications. Scan a medicine to set a reminder.')),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: activeReminders.length,
                itemBuilder: (context, index) => _buildReminderCard(context, activeReminders[index], provider),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildReminderCard(BuildContext context, MedicationReminder reminder, ReminderProvider provider) {
    bool isTakenToday = false;
    if (reminder.lastTaken != null) {
      final now = DateTime.now();
      isTakenToday = reminder.lastTaken!.year == now.year && 
                     reminder.lastTaken!.month == now.month && 
                     reminder.lastTaken!.day == now.day;
    }

    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTakenToday ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isTakenToday ? Colors.green.withOpacity(0.3) : Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  reminder.medicationName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(isTakenToday ? Icons.check_circle : Icons.access_time, 
                   color: isTakenToday ? Colors.green : Colors.blue, size: 20),
            ],
          ),
          const SizedBox(height: 4),
          Text('${reminder.dosage} • ${reminder.time.format(context)}', 
               style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isTakenToday ? null : () => provider.markAsTaken(reminder.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isTakenToday ? 'Taken' : 'Mark Taken'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('Safety Reminder', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'For educational purposes only. Do not make medical decisions based on this app. Consult with your doctor.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class HistoryList extends StatelessWidget {
  const HistoryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalDataProvider>(
      builder: (context, provider, child) {
        if (provider.history.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Icon(Icons.history, size: 48, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  const Text('No recent analyses found.\nScan something to get started!', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.history.length > 5 ? 5 : provider.history.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = provider.history[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _getTypeColor(item.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type))),
              ),
              title: Text(_getItemTitle(item), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Text('${item.timestamp.day}/${item.timestamp.month} • ${_getTypeLabel(item.type)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () {
                if (item.type == 'medication') {
                  provider.currentMedication = item.data as Medication;
                } else if (item.type == 'document') {
                  provider.currentDocument = item.data as MedicalDocument;
                } else if (item.type == 'imaging') {
                  provider.currentImagingResult = item.data as MedicalImagingResult;
                }
                provider.currentImagePath = item.imagePath;
                Navigator.pushNamed(context, '/results');
              },
            );
          },
        );
      },
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'medication': return Icons.medication_liquid;
      case 'document': return Icons.description;
      case 'imaging': return Icons.biotech;
      default: return Icons.help_outline;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'medication': return Colors.teal;
      case 'document': return Colors.blue;
      case 'imaging': return Colors.purple;
      default: return Colors.grey;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'medication': return 'Medicine';
      case 'document': return 'Document';
      case 'imaging': return 'Imaging';
      default: return 'Analysis';
    }
  }

  String _getItemTitle(HistoryItem item) {
    if (item.type == 'medication') return (item.data as Medication).name;
    if (item.type == 'document') return (item.data as MedicalDocument).documentType.toUpperCase();
    if (item.type == 'imaging') return (item.data as MedicalImagingResult).imagingType;
    return 'Analysis Result';
  }
}
