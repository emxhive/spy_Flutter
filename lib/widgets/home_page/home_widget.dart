import 'package:flutter/material.dart';
import 'package:spy/helpers/firestore_helpers.dart';
import 'package:spy/widgets/home_page/pm_widget.dart';
import 'package:spy/widgets/track_page/track_helpers/classes_track.dart';
import 'balance_widget.dart';

class HomeBase extends StatelessWidget {
  const HomeBase({super.key});



  @override
  Widget build(BuildContext context) {

    return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        child: Column(
          children: [
            HeaderW(),
            SizedBox(
              height: 20,
            ),
            BalanceW(),
            SizedBox(height: 20),
            PMW()
          ],
        ));
  }
}

class HeaderW extends StatelessWidget {
  const HeaderW({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(children: [
      Icon(Icons.supervised_user_circle_outlined),
      SizedBox(width: 15),
      Text("Ezekiel")
    ]);
  }
}
