import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spy/helpers/firestore_helpers.dart';
import 'package:spy/helpers/sqflite_manager.dart';
import 'package:spy/widgets/home_page/home_widget.dart';

import 'package:spy/widgets/track_page/track_widget.dart';
import 'external/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DB().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const NavigatorW(),
        theme: ThemeData(
            useMaterial3: true,
            textTheme:
                GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)));
  }
}

class NavigatorW extends StatefulWidget {
  const NavigatorW({super.key});

  @override
  State<NavigatorW> createState() => _NavigatorWState();
}

class _NavigatorWState extends State<NavigatorW> {
  final iconData = {
    "Home": Icons.home,
    "Track": Icons.track_changes,
    "History": Icons.history
  };
  int currentIndex = 0;
  var futureReference = PMD().init();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (index) => setState(() {
          currentIndex = index;
        }),
        selectedIndex: currentIndex,
        destinations: <Widget>[
          ...iconData.keys.map((key) =>
              NavigationDestination(icon: Icon(iconData[key]), label: key))
        ],
      ),
      body: FutureBuilder(
          future: futureReference,
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.hasData && snapshot.data == true) {
              return const <Widget>[
                HomeBase(),
                TrackBase(),
                HomeBase()
              ][currentIndex];
            } else {
              return const Center(child: Text('🥲'));
            }
          }),
    ));
  }
}
