import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import '../services/ad_service.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({
    super.key,
    this.size = AdSize.banner,
    this.margin = const EdgeInsets.symmetric(vertical: 8),
  });

  final AdSize size;
  final EdgeInsetsGeometry margin;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _request();
  }

  void _request() {
    if (_requested) return;
    _requested = true;
    final service = context.read<AdService>();
    if (!service.bannerAvailable) return;
    final ad = service.createBanner(
      size: widget.size,
      onLoaded: (_) {
        if (mounted) setState(() => _loaded = true);
      },
      onFailed: (_, error) {
        debugPrint('banner failed: ${error.message}');
      },
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return Padding(
      padding: widget.margin,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
