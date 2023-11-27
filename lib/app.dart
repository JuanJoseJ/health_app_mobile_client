import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/authentication/auth_gate.dart';
import 'package:health_app_mobile_client/themes/primary_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: kCustomGreenTheme,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: const AuthGate(),
    );
  }
}

