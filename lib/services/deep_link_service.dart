import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../utils/app_logger.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void init(BuildContext context) {
    _appLinks = AppLinks();
    
    // Handle app start with a link
    _handleInitialLink(context);

    // Handle deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleLink(context, uri);
    }, onError: (err) {
      AppLogger.error('Deep link error', err);
    });
  }

  Future<void> _handleInitialLink(BuildContext context) async {
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleLink(context, initialLink);
      }
    } catch (e) {
      AppLogger.error('Failed to get initial deep link', e);
    }
  }

  void _handleLink(BuildContext context, Uri uri) {
    AppLogger.info('Deep link received: $uri');
    
    // Path: aimedic://results?id=xyz
    if (uri.path == '/results' || uri.host == 'results') {
      final resultId = uri.queryParameters['id'];
      if (resultId != null) {
        // Navigate to results screen with the specific ID
        // For now, just navigate to the results screen
        Navigator.of(context).pushNamed('/results', arguments: resultId);
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
