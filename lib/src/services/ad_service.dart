import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../core/app_config.dart';

class AdService {
  AdService(this.config);

  final AppConfig config;

  InterstitialAd? _interstitial;
  bool _loadingInterstitial = false;

  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<void> initialize(AppConfig config) async {
    if (!isSupported || !config.hasAds) return;
    await MobileAds.instance.initialize();
  }

  bool get bannerAvailable => isSupported && config.bannerUnitId != null;

  bool get interstitialAvailable =>
      isSupported && config.interstitialUnitId != null;

  BannerAd createBanner({
    AdSize size = AdSize.banner,
    void Function(Ad ad)? onLoaded,
    void Function(Ad ad, LoadAdError error)? onFailed,
  }) {
    final unitId = config.bannerUnitId;
    if (unitId == null) {
      throw StateError('bannerUnitId is not configured in AppConfig.');
    }
    return BannerAd(
      size: size,
      adUnitId: unitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onLoaded,
        onAdFailedToLoad: onFailed,
      ),
    );
  }

  Future<void> loadInterstitial({
    void Function()? onLoaded,
    void Function(LoadAdError error)? onFailed,
  }) {
    final unitId = config.interstitialUnitId;
    if (unitId == null || !isSupported || _loadingInterstitial) {
      return Future<void>.value();
    }
    _loadingInterstitial = true;
    return InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _loadingInterstitial = false;
          _interstitial = ad;
          onLoaded?.call();
        },
        onAdFailedToLoad: (error) {
          _loadingInterstitial = false;
          _interstitial = null;
          onFailed?.call(error);
        },
      ),
    );
  }

  Future<bool> showInterstitial() async {
    final ad = _interstitial;
    if (ad == null) return false;
    _interstitial = null;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) => ad.dispose(),
      onAdFailedToShowFullScreenContent: (ad, error) => ad.dispose(),
    );
    await ad.show();
    return true;
  }
}
