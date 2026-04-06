import 'package:flutter/material.dart';
import 'app_constants.dart';

/// Reusable app widgets for consistent design
class AppWidgets {
  /// Loading indicator widget
  static Widget loadingIndicator({Color? color}) {
    return Center(
      child: CircularProgressIndicator(color: color, strokeWidth: 2.5),
    );
  }

  /// Error widget with retry button
  static Widget errorWidget({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  /// Empty state widget
  static Widget emptyState({
    required String message,
    IconData icon = Icons.inbox_outlined,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: AppConstants.paddingMedium),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppConstants.paddingLarge),
            ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }

  /// Section title widget
  static Widget sectionTitle(String title, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      child: Text(
        title,
        style:
            style ?? const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Smooth card with consistent styling
  static Widget smoothCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(AppConstants.paddingMedium),
    Color? backgroundColor,
    GestureTapCallback? onTap,
  }) {
    return Card(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(padding: padding, child: child),
      ),
    );
  }

  /// Divider with custom styling
  static Widget customDivider({Color? color, double? height}) {
    return Divider(
      color: color ?? Colors.grey.withValues(alpha: 0.3),
      height: height ?? AppConstants.paddingMedium,
    );
  }
}
