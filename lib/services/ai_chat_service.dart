import '../models/models.dart';

class AIChatService {
  Future<String> getResponse(String query, Map<String, dynamic> context) async {
    // Simulate thinking delay
    await Future.delayed(const Duration(seconds: 1));

    final lowerQuery = query.toLowerCase();
    final profile = context['profile'] as UserProfile?;
    final history = context['history'] as List<HistoryItem>? ?? [];

    // Context analysis
    final hasMeds = history.any((h) => h.type == 'medication');
    final hasDocs = history.any((h) => h.type == 'document');
    
    // Simple rule-based "AI" responses
    if (lowerQuery.contains('hello') || lowerQuery.contains('hi')) {
      return "Hello! I'm your AI health assistant. I can help you understand your medications, lab results, and health trends. How can I assist you today?";
    }

    if (lowerQuery.contains('side effect')) {
      if (hasMeds) {
        final lastMed = history.firstWhere((h) => h.type == 'medication').data as Medication;
        return "Regarding ${lastMed.name}, common side effects include: ${lastMed.sideEffects.take(3).join(', ')}. Please monitor for these and contact your doctor if they persist.";
      }
      return "I don't see any recent medication scans in your history. Could you please scan a medicine first so I can provide specific side effect information?";
    }

    if (lowerQuery.contains('lab result') || lowerQuery.contains('glucose') || lowerQuery.contains('blood')) {
      if (hasDocs) {
        final lastDoc = history.firstWhere((h) => h.type == 'document').data as MedicalDocument;
        final abnormal = lastDoc.abnormalValues;
        if (abnormal.isNotEmpty) {
          return "I've analyzed your latest results. I noticed some values outside the normal range: ${abnormal.join(', ')}. These might indicate something your doctor should review. Would you like me to explain what these specific values usually mean?";
        }
        return "Your latest lab results look good! All key findings were within normal ranges. It's still important to discuss them with your doctor during your next visit.";
      }
      return "I don't have your latest lab results yet. You can scan your blood test or medical report using the 'Scan Docs' feature on the Home screen.";
    }

    if (lowerQuery.contains('interaction') || lowerQuery.contains('safe')) {
      String safetyInfo = "";
      if (profile != null && profile.medicalConditions.isNotEmpty) {
        safetyInfo = "Given your profile mentions ${profile.medicalConditions.join(', ')}, I'm being extra careful. ";
      }
      
      if (hasMeds && history.where((h) => h.type == 'medication').length > 1) {
        return "${safetyInfo}I'm monitoring your active medications for interactions. Your current combination looks safe according to my database, but always check for new symptoms and consult your pharmacist.";
      }
      return "${safetyInfo}To check for interactions, I need at least two medications in your active list. You can add more by scanning them.";
    }

    if (lowerQuery.contains('thank')) {
      return "You're very welcome! Is there anything else I can help you with today?";
    }

    // Individual medication safety check
    if (lowerQuery.contains('can i take') || lowerQuery.contains('is it ok')) {
       if (hasMeds) {
        final lastMed = history.firstWhere((h) => h.type == 'medication').data as Medication;
        if (profile != null) {
          final conflicts = profile.medicalConditions.where((c) => 
            lastMed.contraindications.any((contra) => contra.toLowerCase().contains(c.toLowerCase()))).toList();
          if (conflicts.isNotEmpty) {
            return "Actually, you should be cautious. ${lastMed.name} is generally not recommended for people with ${conflicts.join(' and ')}. Please double-check with your doctor.";
          }
        }
        return "Based on your current profile, I don't see any immediate reason why you couldn't take ${lastMed.name}, but I'm just an AI. Always follow your doctor's orders.";
      }
    }

    // Default response using context
    String contextGreeting = profile != null ? "Since you're ${profile.name}, I'm focusing on your profile's specific needs (Allergies: ${profile.allergies.isEmpty ? 'None' : profile.allergies.join(', ')}). " : "";
    return "${contextGreeting}I'm not entirely sure I understand your specific question about '$query'. Try asking me about 'side effects', 'lab results', or 'medication interactions'.";
  }
}
