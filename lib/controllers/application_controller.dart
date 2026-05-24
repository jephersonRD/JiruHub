import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiruhub/utils/jiruhub_storage.dart';

class ApplicationController extends GetxController {
  static get find => Get.find();

  final themeText = "system".obs;

  static const List<String> cjkFontFallback = [
    "Noto Sans CJK JP",
    "Noto Sans CJK KR",
    "Noto Sans CJK TC",
    "Noto Sans CJK HK",
    "Microsoft Yahei",
    "SimSun",
    "Arial Unicode MS",
  ];

  @override
  void onInit() {
    themeText.value = JiruHubStorage.getSetting(SettingKey.theme);
    super.onInit();
  }

  TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.dark ? Colors.white : Colors.black;
    return TextTheme(
      displayLarge: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      displayMedium: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      displaySmall: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      headlineLarge: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      headlineMedium: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      headlineSmall: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      titleLarge: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      titleMedium: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      titleSmall: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      bodyLarge: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      bodyMedium: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      bodySmall: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      labelLarge: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      labelMedium: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
      labelSmall: TextStyle(fontFamily: "Noto Sans CJK SC", fontFamilyFallback: cjkFontFallback, color: color),
    );
  }

  ThemeData get currentThemeData {
    switch (themeText.value) {
      case "light":
        return ThemeData.light(useMaterial3: true).copyWith(
          textTheme: _buildTextTheme(Brightness.light),
        );
      case "dark":
        return ThemeData.dark(useMaterial3: true).copyWith(
          textTheme: _buildTextTheme(Brightness.dark),
        );
      case "black":
        return ThemeData.dark(
          useMaterial3: true,
        ).copyWith(
          scaffoldBackgroundColor: Colors.black,
          canvasColor: Colors.black,
          cardColor: Colors.black,
          dialogBackgroundColor: Colors.black,
          primaryColor: Colors.black,
          hintColor: Colors.black,
          primaryColorDark: Colors.black,
          primaryColorLight: Colors.black,
          textTheme: _buildTextTheme(Brightness.dark),
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onBackground: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            secondary: Colors.grey,
            surface: Colors.black,
            background: Colors.black,
            onPrimary: Colors.black,
            primaryContainer: Color.fromARGB(255, 31, 31, 31),
            surfaceTint: Colors.black,
          ),
        );
      default:
        return ThemeData.light(useMaterial3: true).copyWith(
          textTheme: _buildTextTheme(Brightness.light),
        );
    }
  }

  ThemeMode get theme {
    switch (themeText.value) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "black":
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  changeTheme(String mode) {
    JiruHubStorage.setSetting(SettingKey.theme, mode);
    themeText.value = mode;
    Get.forceAppUpdate();
  }
}
