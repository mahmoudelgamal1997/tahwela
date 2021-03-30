import 'package:flutter/material.dart';
import 'package:tahwela/screens/RocketLaunchDetailsScreen.dart';
import 'package:tahwela/screens/tabsScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'SpaceX',
        theme: ThemeData(
            primarySwatch: Colors.teal,
            accentColor: Colors.teal[600],
            fontFamily: 'Quicksand'),
        home: TabsScreen(),
        routes: {
          RocketLaunchDetailsScreen.routeName: (ctx) =>
              RocketLaunchDetailsScreen(),
        });
  }
}