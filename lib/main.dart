// lib/main.dart
// Entry point for Flashlight App

import ‘package:flutter/material.dart’;
import ‘package:google_mobile_ads/google_mobile_ads.dart’;
import ‘package:shared_preferences/shared_preferences.dart’;
import ‘screens/home_screen.dart’;
import ‘services/subscription_service.dart’;

void main() async {
WidgetsFlutterBinding.ensureInitialized();
await MobileAds.instance.initialize();
runApp(const FlashlightApp());
}

class FlashlightApp extends StatelessWidget {
const FlashlightApp({super.key});

@override
Widget build(BuildContext context) {
return MaterialApp(
title: ‘Flashlight’,
debugShowCheckedModeBanner: false,
theme: ThemeData(
colorScheme: ColorScheme.fromSeed(
seedColor: const Color(0xFFFFD700),
brightness: Brightness.dark,
),
useMaterial3: true,
),
home: const HomeScreen(),
);
}
}
