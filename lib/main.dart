import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/app.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "health_app_mobile_client",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
