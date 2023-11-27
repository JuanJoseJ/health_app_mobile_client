import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/colors/primary_colors.dart';

final ThemeData kCustomGreenTheme = _buildCustomGreenTheme();

ThemeData _buildCustomGreenTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: kGreen900,
      onPrimary: Colors.white,
      secondary: kGreen400,
      onSecondary: kGreen900,
      error: kErrorRed,
      background: kGreen100,
    ),
    textTheme: _buildCustomGreenTextTheme(base.textTheme),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: kGreen100,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: kGreen900,
        ),
      ),
      floatingLabelStyle: TextStyle(
        color: kGreen900,
      ),
    ),
  );
}

TextTheme _buildCustomGreenTextTheme(TextTheme base) {
  return base
      .copyWith(
        headlineSmall: base.headlineSmall!.copyWith(
          fontWeight: FontWeight.w500,
        ),
        titleLarge: base.titleLarge!.copyWith(
          fontSize: 18.0,
        ),
        bodySmall: base.bodySmall!.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 14.0,
        ),
        bodyLarge: base.bodyLarge!.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
        ),
      )
      .apply(
        fontFamily: 'Rubik',
        displayColor: kGreen900,
        bodyColor: kGreen900,
      );
}