import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/app_config.dart';

class RateService {
  RateService(this.config);

  final AppConfig config;

  String? get storeUrl {
    if (kIsWeb) return config.playStoreUrl ?? config.appStoreUrl;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return config.playStoreUrl ?? config.appStoreUrl;
      case TargetPlatform.iOS:
        return config.appStoreUrl ?? config.playStoreUrl;
      default:
        return config.playStoreUrl ?? config.appStoreUrl;
    }
  }

  Future<bool> openStore() async {
    final url = storeUrl;
    if (url == null) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<bool> openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
