import 'dart:ui' show Rect;

import 'package:share_plus/share_plus.dart';

import '../core/app_config.dart';

class ShareService {
  ShareService(this.config);

  final AppConfig config;

  Future<void> shareApp({String? text, String? subject, Rect? origin}) async {
    final url = config.playStoreUrl ?? config.appStoreUrl;
    final message = text ?? '${config.appName}${url == null ? '' : '\n$url'}';
    await SharePlus.instance.share(
      ShareParams(
        text: message,
        subject: subject ?? config.appName,
        sharePositionOrigin: origin,
      ),
    );
  }

  Future<void> shareText(String text, {String? subject, Rect? origin}) {
    return SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
  }
}
