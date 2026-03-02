import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {

  bool isBlind = true;
  bool isDeaf = false;
  bool isMute = false;
  bool largeText = false;
  bool highContrast = false;

  Future<void> loadAccessibility() async {
    final prefs = await SharedPreferences.getInstance();

    isBlind = prefs.getBool("isBlind") ?? false;
    isDeaf = prefs.getBool("isDeaf") ?? false;
    isMute = prefs.getBool("isMute") ?? false;
    largeText = prefs.getBool("largeText") ?? false;
    highContrast = prefs.getBool("highContrast") ?? false;

    notifyListeners();
  }

  Future<void> setAccessibility({
    bool? blind,
    bool? deaf,
    bool? mute,
  }) async {

    final prefs = await SharedPreferences.getInstance();

    if (blind != null) {
      isBlind = blind;
      await prefs.setBool("isBlind", blind);
    }

    if (deaf != null) {
      isDeaf = deaf;
      await prefs.setBool("isDeaf", deaf);
    }

    if (mute != null) {
      isMute = mute;
      await prefs.setBool("isMute", mute);
    }

    largeText = isBlind || isMute;
    highContrast = isBlind || isDeaf;

    await prefs.setBool("largeText", largeText);
    await prefs.setBool("highContrast", highContrast);

    notifyListeners();
  }
}