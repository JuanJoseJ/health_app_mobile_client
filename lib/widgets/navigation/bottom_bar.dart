import 'package:flutter/material.dart';

class MyBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  MyBottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu_book),
          label: 'Learn',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_circle),
          label: 'Account',
          
        ),
        // Add more items as needed
      ],
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
    );
  }
}
