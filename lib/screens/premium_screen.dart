// lib/screens/premium_screen.dart
// Premium subscription paywall — $2/month

import ‘package:flutter/material.dart’;
import ‘../services/subscription_service.dart’;

class PremiumScreen extends StatefulWidget {
final SubscriptionService subscriptionService;
const PremiumScreen({super.key, required this.subscriptionService});

@override
State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
bool _isLoading = false;

Future<void> _subscribe() async {
setState(() => _isLoading = true);
try {
final success = await widget.subscriptionService.subscribe();
if (success && mounted) {
Navigator.pop(context);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text(‘Welcome to Premium! 🎉’)),
);
}
} catch (e) {
if (mounted) {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(‘Purchase failed: $e’)),
);
}
} finally {
if (mounted) setState(() => _isLoading = false);
}
}

Future<void> _restore() async {
setState(() => _isLoading = true);
await widget.subscriptionService.restorePurchases();
if (mounted) {
setState(() => _isLoading = false);
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text(‘Purchases restored!’)),
);
}
}

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: const Color(0xFF1A1A2E),
appBar: AppBar(
backgroundColor: Colors.transparent,
elevation: 0,
leading: IconButton(
icon: const Icon(Icons.close, color: Colors.white),
onPressed: () => Navigator.pop(context),
),
),
body: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.center,
children: [
const Icon(Icons.workspace_premium, size: 80, color: Color(0xFFFFD700)),
const SizedBox(height: 16),
const Text(
‘Go Premium’,
style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
),
const SizedBox(height: 8),
const Text(
‘Unlock all features for just $2/month’,
style: TextStyle(fontSize: 16, color: Colors.grey),
textAlign: TextAlign.center,
),
const SizedBox(height: 40),
_buildFeatureRow(Icons.sos, ‘SOS Mode’, ‘Emergency SOS signal’),
_buildFeatureRow(Icons.flash_auto, ‘Strobe Effect’, ‘Customizable strobe speed’),
_buildFeatureRow(Icons.block, ‘No Ads’, ‘Completely ad-free experience’),
_buildFeatureRow(Icons.speed, ‘Adjustable Brightness’, ‘Fine-tune screen brightness’),
const Spacer(),
SizedBox(
width: double.infinity,
height: 56,
child: ElevatedButton(
onPressed: _isLoading ? null : _subscribe,
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFFFFD700),
foregroundColor: Colors.black,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
),
child: _isLoading
? const CircularProgressIndicator(color: Colors.black)
: const Text(
‘Subscribe — $2 / month’,
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
),
),
),
const SizedBox(height: 12),
TextButton(
onPressed: _isLoading ? null : _restore,
child: const Text(‘Restore Purchases’, style: TextStyle(color: Colors.grey)),
),
const SizedBox(height: 8),
const Text(
‘Cancel anytime. Billed monthly through your app store account.’,
style: TextStyle(color: Colors.grey, fontSize: 11),
textAlign: TextAlign.center,
),
],
),
),
);
}

Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 10),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(10),
decoration: BoxDecoration(
color: const Color(0xFFFFD700).withOpacity(0.15),
borderRadius: BorderRadius.circular(12),
),
child: Icon(icon, color: const Color(0xFFFFD700), size: 24),
),
const SizedBox(width: 16),
Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
],
),
const Spacer(),
const Icon(Icons.check_circle, color: Color(0xFFFFD700), size: 20),
],
),
);
}
}
