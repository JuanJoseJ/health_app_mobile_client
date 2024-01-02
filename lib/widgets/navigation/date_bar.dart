import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/my_home_page.dart';
import 'package:provider/provider.dart';

class DateBar extends StatelessWidget implements PreferredSizeWidget {
  const DateBar({Key? key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDateProvider>(builder: (context, hDataProvider, child) {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1,
        centerTitle: true,
        title: Text(
          "${hDataProvider.currentDate.year}-${hDataProvider.currentDate.month}-${hDataProvider.currentDate.day}",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          onPressed: () {
            hDataProvider.updateCurrentDate(
                hDataProvider.currentDate.subtract(const Duration(days: 1)));
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final startOfDay = DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day
                );
              if (hDataProvider.currentDate.isBefore(startOfDay)) {
                hDataProvider.updateCurrentDate(
                    hDataProvider.currentDate.add(const Duration(days: 1)));
              }else{
                null;
              }
            },
            icon: Icon(Icons.arrow_forward, color: Colors.black),
          ),
        ],
      );
    });
  }
}
