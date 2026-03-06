// lib/services/ad_service.dart
// Manages banner and interstitial ads for free users

import ‘package:google_mobile_ads/google_mobile_ads.dart’;
import ‘package:flutter/foundation.dart’;

class AdService {
// Replace these with your real AdMob IDs before release
static const String _bannerAdUnitIdAndroid = ‘ca-app-pub-9259989243431817/8603212738’;
static const String _bannerAdUnitIdIOS     = ‘ca-app-pub-9259989243431817/7645354285’;
static const String _interstitialAdUnitIdAndroid = ‘ca-app-pub-9259989243431817/7098559376’;
static const String _interstitialAdUnitIdIOS     = ‘ca-app-pub-9259989243431817/2876572904’;

// Use test ads during development
static String get bannerAdUnitId {
if (kDebugMode) {
return defaultTargetPlatform == TargetPlatform.iOS
? ‘ca-app-pub-3940256099942544/2934735716’
: ‘ca-app-pub-3940256099942544/6300978111’;
}
return defaultTargetPlatform == TargetPlatform.iOS
? _bannerAdUnitIdIOS
: _bannerAdUnitIdAndroid;
}

static String get interstitialAdUnitId {
if (kDebugMode) {
return defaultTargetPlatform == TargetPlatform.iOS
? ‘ca-app-pub-3940256099942544/4411468910’
: ‘ca-app-pub-3940256099942544/1033173712’;
}
return defaultTargetPlatform == TargetPlatform.iOS
? _interstitialAdUnitIdIOS
: _interstitialAdUnitIdAndroid;
}

BannerAd? _bannerAd;
InterstitialAd? _interstitialAd;

BannerAd? get bannerAd => _bannerAd;

Future<void> loadBannerAd({required VoidCallback onLoaded}) async {
*bannerAd = BannerAd(
adUnitId: bannerAdUnitId,
size: AdSize.banner,
request: const AdRequest(),
listener: BannerAdListener(
onAdLoaded: (*) => onLoaded(),
onAdFailedToLoad: (ad, error) {
ad.dispose();
_bannerAd = null;
debugPrint(‘Banner ad failed: $error’);
},
),
);
await _bannerAd!.load();
}

Future<void> loadInterstitialAd() async {
await InterstitialAd.load(
adUnitId: interstitialAdUnitId,
request: const AdRequest(),
adLoadCallback: InterstitialAdLoadCallback(
onAdLoaded: (ad) => _interstitialAd = ad,
onAdFailedToLoad: (error) => debugPrint(‘Interstitial failed: $error’),
),
);
}

void showInterstitialAd() {
_interstitialAd?.show();
_interstitialAd = null;
}

void dispose() {
_bannerAd?.dispose();
_interstitialAd?.dispose();
}
}
