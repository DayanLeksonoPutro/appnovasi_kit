import 'package:url_launcher/url_launcher.dart';

class LinkService {
  const LinkService();

  Future<bool> open(
    String? url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    if (url == null || url.isEmpty) return false;
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return launchUrl(uri, mode: mode);
  }
}
