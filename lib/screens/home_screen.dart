// lib/screens/home_screen.dart
// Main screen: flashlight toggle, SOS mode, brightness slider, screen light

import ‘package:flutter/material.dart’;
import ‘package:flutter/services.dart’;
import ‘package:google_mobile_ads/google_mobile_ads.dart’;
import ‘package:torch_light/torch_light.dart’;
import ‘../services/ad_service.dart’;
import ‘../services/subscription_service.dart’;
import ‘premium_screen.dart’;

class HomeScreen extends StatefulWidget {
const HomeScreen({super.key});

@override
State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
final AdService _adService = AdService();
final SubscriptionService _subService = SubscriptionService();

bool _isFlashlightOn = false;
bool _isSosMode = false;
bool _isScreenLight = false;
bool _isBannerAdLoaded = false;
double _screenBrightness = 1.0;

@override
void initState() {
super.initState();
WidgetsBinding.instance.addObserver(this);
_subService.addListener(_onSubscriptionChanged);
_loadAds();
}

void _onSubscriptionChanged() {
setState(() {});
if (_subService.isPremium) {
_adService.dispose();
}
}

Future<void> _loadAds() async {
if (_subService.isPremium) return;
await _adService.loadBannerAd(onLoaded: () {
if (mounted) setState(() => _isBannerAdLoaded = true);
});
await _adService.loadInterstitialAd();
}

Future<void> _toggleFlashlight() async {
try {
if (_isFlashlightOn) {
await TorchLight.disableTorch();
} else {
await TorchLight.enableTorch();
// Show interstitial every time torch is turned on (free users only)
if (!_subService.isPremium) {
_adService.showInterstitialAd();
await _adService.loadInterstitialAd();
}
}
setState(() => _isFlashlightOn = !_isFlashlightOn);
} on Exception catch (e) {
_showError(‘Could not control flashlight: $e’);
}
}

Future<void> _toggleSos() async {
if (!_subService.isPremium) {
_navigateToPremium();
return;
}
setState(() => _isSosMode = !_isSosMode);
if (_isSosMode) _runSos();
}

Future<void> _runSos() async {
// SOS: … — …
final pattern = [1,1,1,3,3,3,1,1,1]; // dots and dashes
while (_isSosMode) {
for (int i = 0; i < pattern.length; i++) {
if (!_isSosMode) break;
await TorchLight.enableTorch();
await Future.delayed(Duration(milliseconds: pattern[i] * 200));
await TorchLight.disableTorch();
await Future.delayed(const Duration(milliseconds: 200));
}
await Future.delayed(const Duration(milliseconds: 800));
}
}

void _toggleScreenLight() {
setState(() => _isScreenLight = !_isScreenLight);
}

void *navigateToPremium() {
Navigator.push(context, MaterialPageRoute(
builder: (*) => PremiumScreen(subscriptionService: _subService),
));
}

void _showError(String message) {
ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

@override
void didChangeAppLifecycleState(AppLifecycleState state) {
if (state == AppLifecycleState.paused) {
if (_isFlashlightOn) TorchLight.disableTorch();
if (_isSosMode) setState(() => _isSosMode = false);
}
}

@override
void dispose() {
if (_isFlashlightOn) TorchLight.disableTorch();
_adService.dispose();
_subService.removeListener(_onSubscriptionChanged);
_subService.dispose();
WidgetsBinding.instance.removeObserver(this);
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: _isScreenLight ? Colors.white : const Color(0xFF1A1A2E),
appBar: _isScreenLight
? null
: AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
title: const Text(
‘🔦 Flashlight’,
style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
),
actions: [
if (!_subService.isPremium)
TextButton(
onPressed: _navigateToPremium,
child: const Text(
‘GO PREMIUM’,
style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
),
),
IconButton(
icon: const Icon(Icons.settings, color: Colors.white),
onPressed: () {},
),
],
),
body: Column(
children: [
Expanded(child: _buildMainContent()),
if (!_subService.isPremium && _isBannerAdLoaded)
SizedBox(
height: 50,
child: AdWidget(ad: _adService.bannerAd!),
),
],
),
);
}

Widget _buildMainContent() {
if (_isScreenLight) {
return GestureDetector(
onTap: _toggleScreenLight,
child: Container(
color: Colors.white,
child: const Center(
child: Text(
‘Tap to exit screen light’,
style: TextStyle(color: Colors.grey, fontSize: 16),
),
),
),
);
}

```
return Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Main flashlight button
      GestureDetector(
        onTap: _toggleFlashlight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isFlashlightOn
                ? const Color(0xFFFFD700)
                : const Color(0xFF2D2D44),
            boxShadow: _isFlashlightOn
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 10,
                    )
                  ]
                : [],
          ),
          child: Icon(
            Icons.flashlight_on,
            size: 80,
            color: _isFlashlightOn ? Colors.black : Colors.grey,
          ),
        ),
      ),

      const SizedBox(height: 16),
      Text(
        _isFlashlightOn ? 'ON' : 'OFF',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: _isFlashlightOn ? const Color(0xFFFFD700) : Colors.grey,
        ),
      ),

      const SizedBox(height: 48),

      // Feature row
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFeatureButton(
            icon: Icons.screen_brightness_high,
            label: 'Screen\nLight',
            onTap: _toggleScreenLight,
            isPremium: false,
            isActive: _isScreenLight,
          ),
          _buildFeatureButton(
            icon: Icons.sos,
            label: 'SOS\nMode',
            onTap: _toggleSos,
            isPremium: true,
            isActive: _isSosMode,
          ),
          _buildFeatureButton(
            icon: Icons.flash_auto,
            label: 'Strobe\nEffect',
            onTap: () {
              if (!_subService.isPremium) _navigateToPremium();
            },
            isPremium: true,
            isActive: false,
          ),
        ],
      ),
    ],
  ),
);
```

}

Widget _buildFeatureButton({
required IconData icon,
required String label,
required VoidCallback onTap,
required bool isPremium,
required bool isActive,
}) {
final isLocked = isPremium && !_subService.isPremium;
return GestureDetector(
onTap: onTap,
child: Container(
width: 90,
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: isActive ? const Color(0xFFFFD700).withOpacity(0.2) : const Color(0xFF2D2D44),
borderRadius: BorderRadius.circular(16),
border: isActive
? Border.all(color: const Color(0xFFFFD700), width: 2)
: null,
),
child: Column(
children: [
Stack(
alignment: Alignment.topRight,
children: [
Icon(icon, color: isActive ? const Color(0xFFFFD700) : Colors.grey, size: 30),
if (isLocked)
const Icon(Icons.lock, color: Color(0xFFFFD700), size: 14),
],
),
const SizedBox(height: 8),
Text(
label,
textAlign: TextAlign.center,
style: TextStyle(
color: isActive ? const Color(0xFFFFD700) : Colors.grey,
fontSize: 11,
),
),
],
),
),
);
}
}
