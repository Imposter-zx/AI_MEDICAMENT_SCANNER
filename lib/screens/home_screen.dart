import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medical_data_provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildHeader(context),
              const SizedBox(height: 24),

              // Main Features
              const Text(
                'Choose a Feature',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(child: _buildSmallFeatureCard(context, 'assets/icons/medication_icon.png', 'Med Scan', '/medication-scan')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSmallFeatureCard(context, 'assets/icons/document_scanner_icon.png', 'Docs', '/document-analysis')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildSmallFeatureCard(context, 'assets/icons/medical_imaging_icon.png', 'Imaging', '/medical-imaging')),
                ],
              ),
              
              const SizedBox(height: 32),

              // Recent History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Analyses',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      // Logic to view all history if needed
                    },
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              const HistoryList(),
              
              const SizedBox(height: 32),

              // Safety Guidelines
              _buildSafetyNotice(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.profile;
        final name = profile?.name ?? "Guest";
        
        // Dynamic greeting based on time of day
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
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
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
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
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
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
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

  Widget _buildSmallFeatureCard(BuildContext context, String assetPath, String title, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Image.asset(assetPath, height: 40, width: 40),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
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
              Text(
                'Safety Reminder',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
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
                  const Text(
                    'No recent analyses found.\nScan something to get started!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
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
                child: Center(
                  child: Icon(_getTypeIcon(item.type), color: _getTypeColor(item.type)),
                ),
              ),
              title: Text(
                _getItemTitle(item),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              subtitle: Text(
                '${item.timestamp.day}/${item.timestamp.month} • ${_getTypeLabel(item.type)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () {
                // Set as current results and navigate
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

class FeatureCard extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.blue),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
