import 'package:flutter/material.dart';

class MyTopBar extends StatelessWidget implements PreferredSizeWidget {
  const MyTopBar({super.key});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(
        "Health Application",
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      actions: [], 
    );
  }
}
