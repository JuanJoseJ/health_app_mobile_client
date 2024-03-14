import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

class ProfileBlock extends StatefulWidget {
  const ProfileBlock({super.key});

  @override
  State<ProfileBlock> createState() => _ProfileBlockState();
}

class _ProfileBlockState extends State<ProfileBlock> {
  @override
  Widget build(BuildContext context) {
    return ProfileScreen();
  }
}
