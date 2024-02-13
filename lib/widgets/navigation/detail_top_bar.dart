import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:provider/provider.dart';

class DetailTopBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic Function(String)? notifyParent;
  final String chartId;
  const DetailTopBar({Key? key, required this.notifyParent, required this.chartId});
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hDataProvider, child) {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            notifyParent!(chartId);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(
              "Activity in Detail",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    });
  }
}
