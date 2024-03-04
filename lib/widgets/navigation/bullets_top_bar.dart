import 'package:flutter/material.dart';
import 'package:health_app_mobile_client/pages/home_provider.dart';
import 'package:health_app_mobile_client/services/fire_store_data_service.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class BulletsTopBar extends StatelessWidget implements PreferredSizeWidget {
  const BulletsTopBar({Key? key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _getTopBarString(String topBarSelect, DateTime currentDate) {
    String newString = "";
    newString = DateFormat('y-MMMM-d').format(currentDate);
    return newString;
  }

  void _updateDate(BuildContext context, HomeDataProvider provider,
      {required bool isForward}) async {
    DateTime newDate;

    final currentDate = provider.currentBulletDate;

    newDate = isForward
        ? currentDate.add(const Duration(days: 1))
        : currentDate.subtract(const Duration(days: 1));

    // Prevent updating to a future date beyond today
    if (newDate.isAfter(DateTime.now())) {
      newDate = DateTime.now();
    }

    // Fetch or assign a lesson for the new date
    Map<String, dynamic> lessonForNewDate =
        await provider.getTodayLesson(date: newDate);

    // Update the provider with the new date and lesson
    provider.updateCurrentBulletDate(newDate);
    provider.updateCurrentLesson(lessonForNewDate);
  }

  Future<void> _selectDate(
      BuildContext context, HomeDataProvider provider) async {
    FireStoreDataService fds = FireStoreDataService();
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: provider.currentBulletDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    late DateTime startDate;
    DateTime currentDate = provider.currentBulletDate;

    if (picked != null && picked != currentDate) {
      provider.updateCurrentBulletDate(picked);
      if (picked.isBefore(currentDate) || picked.isAfter(currentDate)) {
        startDate = DateTime(picked.year, picked.month, picked.day);
        Map<String, dynamic> lessonForNewDate =
            await fds.getTodayLesson(provider.uid, date: startDate);
        provider.updateCurrentLesson(lessonForNewDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeDataProvider>(builder: (context, hdp, child) {
      return AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 1,
        centerTitle: true,
        title: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () =>
                        _updateDate(context, hdp, isForward: false),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, hdp),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getTopBarString(hdp.currentTopBarSelect,
                                  hdp.currentBulletDate),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                    ),
                    onPressed: () => _updateDate(context, hdp, isForward: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
