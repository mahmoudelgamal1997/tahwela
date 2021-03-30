import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dio/dio.dart';
import 'package:tahwela/screens/pastLaunches.dart';
import '../Model/Launch.dart';
import 'futureLaunches.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text("SpaceX"),
            bottom: TabBar(
              tabs: [
                Tab(
                  icon: FaIcon(FontAwesomeIcons.rocket),
                  text: "Next Launch",
                ),
                Tab(icon: Icon(Icons.history), text: "Past Launches")
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FutureLaunchesScreen(),
              PastLaunchesScreen(),
            ],
          ),
        ));
  }
}