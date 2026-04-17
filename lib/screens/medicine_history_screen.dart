import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/medicine_sync_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/premium_background.dart';

class MedicineHistoryScreen extends StatefulWidget {
  const MedicineHistoryScreen({Key? key}) : super(key: key);

  @override
  State<MedicineHistoryScreen> createState() => _MedicineHistoryScreenState();
}

class _MedicineHistoryScreenState extends State<MedicineHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load medicine history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isSignedIn) {
        context.read<MedicineSyncProvider>().loadCachedMedicines();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Medicine History'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumBackground(
        child: Consumer<MedicineSyncProvider>(
          builder: (context, syncProvider, _) {
            if (syncProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            final medicines = syncProvider.cachedMedicines;
            
            if (medicines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No medicine history yet',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.grey.withValues(alpha: 0.6),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scan medicines to see history here',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Start Scanning'),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
              itemCount: medicines.length,
              itemBuilder: (context, index) {
                final medicine = medicines[index];
                final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                  color: Colors.white.withValues(alpha: 0.5),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.medication, color: Theme.of(context).primaryColor),
                    ),
                    title: Text(
                      medicine.medicineName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (medicine.activeIngredient != null)
                          Text(
                            'Active: ${medicine.activeIngredient}',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(medicine.lastScannedDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Scans: ${medicine.scanCount}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: medicine.synced
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    medicine.synced ? Icons.cloud_done : Icons.cloud_upload,
                                    size: 12,
                                    color: medicine.synced ? Colors.green : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    medicine.synced ? 'Synced' : 'Pending',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: medicine.synced ? Colors.green : Colors.orange,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        PopupMenuItem(
                          child: const Text('View Details'),
                          onTap: () {
                            _showMedicineDetails(context, medicine);
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Delete'),
                          onTap: () {
                            _showDeleteConfirmation(
                              context,
                              syncProvider,
                              medicine.medicineId,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<MedicineSyncProvider>().syncUnsyncedMedicines();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.cloud_upload),
        tooltip: 'Sync unsynced medicines',
      ),
    );
  }

  void _showMedicineDetails(BuildContext context, dynamic medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medicine.medicineName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(
                'Active Ingredient:',
                medicine.activeIngredient ?? 'N/A',
              ),
              _buildDetailRow('Manufacturer:', medicine.manufacturer ?? 'N/A'),
              _buildDetailRow('Scan Count:', medicine.scanCount.toString()),
              _buildDetailRow(
                'Last Scanned:',
                DateFormat(
                  'MMM dd, yyyy - HH:mm',
                ).format(medicine.lastScannedDate),
              ),
              _buildDetailRow(
                'Status:',
                medicine.synced ? '✓ Synced' : '⏳ Pending Sync',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    dynamic syncProvider,
    String medicineId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: const Text(
          'Are you sure you want to delete this medicine from history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              syncProvider.deleteMedicine(medicineId);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Medicine deleted')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
