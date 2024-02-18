import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/my_home_page.dart';
import 'package:health_app_mobile_client/widgets/navigation/top_bar.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                  clientId:
                      "696677775400-q2irlnlk9k74dtqdphoocv9cr6l4hq37.apps.googleusercontent.com"),
            ],
            headerBuilder: (context, constraints, shrinkOffset) {
              return AspectRatio(
                aspectRatio: 0.5,
                child: MyTopBar(),
              );
            },
            subtitleBuilder: (context, action) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: action == AuthAction.signIn
                    ? const Text('Welcome, please sign in!')
                    : const Text('Welcome, please sign up!'),
              );
            },
            footerBuilder: (context, action) {
              return const Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  'By signing in, you agree to our terms and conditions.',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            },
          );
        }

        FirebaseFirestore db = FirebaseFirestore.instance;
        User user = snapshot.data!;
        db.collection("users").doc(user.uid).set({
          "UID": user.uid,
        }, SetOptions(merge: true));

        return MainPage(
          title: "Health Application",
          uid: user.uid,
        );
      },
    );
  }
}
