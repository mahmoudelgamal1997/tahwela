import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Model/Launch.dart';
import 'futureLaunches.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class FutureLaunchesScreen extends StatefulWidget {
  @override
  _FutureLaunchesScreenState createState() => _FutureLaunchesScreenState();
}

class _FutureLaunchesScreenState extends State<FutureLaunchesScreen> {
  Launch nextLaunch;
  bool isLoading = false;
  String error = "";
  void toggleIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void getRocketLaunches() async {
    toggleIsLoading();
    String url = "https://api.spacexdata.com/v4/launches/next";
    var dio = Dio();
    try {
      Response response = await dio.get(url);
      nextLaunch = new Launch(
          response.data['id'],
          response.data['name'],
          response.data['date_unix'],
          response.data['launchpad'],
          response.data['links']['youtube_id'],
          response.data['payloads'],
          response.data['rocket'],
          response.data['success']);
      toggleIsLoading();
      controller = CountdownTimerController(
          endTime: response.data['date_unix'] * 1000, onEnd: onEnd);
    } catch (err) {
      toggleIsLoading();
      setState(() {
        error = "An Error Happened";
      });
    }
  }

  void initState() {
    getRocketLaunches();
    super.initState();
  }

  void onEnd() {
    print('onEnd');
  }

  CountdownTimerController controller;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(right: 5),
                  child: FaIcon(
                    FontAwesomeIcons.rocket,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  error.isEmpty ? nextLaunch.name : error,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal),
                ),
              ],
            ),
            nextLaunch.timestamp == null
                ? SizedBox()
                : CountdownTimer(
              controller: controller,
              onEnd: onEnd,
              endTime: nextLaunch.timestamp,
              widgetBuilder: (_, CurrentRemainingTime time) {
                if (time == null) {
                  return Container(
                      width: 100, child: badgeBuilder("00:00"));
                }
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 10),
                      child: Text("The launch is within",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.grey)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        time.days == null
                            ? SizedBox()
                            : badgeBuilder("${time.days} Days"),
                        time.hours == null
                            ? SizedBox()
                            : badgeBuilder("${time.hours} Hours"),
                        time.min == null
                            ? SizedBox()
                            : badgeBuilder("${time.min} Min"),
                        time.sec == null
                            ? SizedBox()
                            : badgeBuilder("${time.sec} Sec")
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/*
Center(
          CountdownTimer(
              controller: controller,
              onEnd: onEnd,
              endTime: endTime,
          ),
      ),
*/
Widget badgeBuilder(String title) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      gradient: LinearGradient(
          colors: [Colors.teal[400], Colors.teal[600]],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.5, 0.0),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp),
    ),
    padding: EdgeInsets.all(6),
    margin: EdgeInsets.only(right: 10),
    alignment: Alignment.center,
    child: Text(
      title,
      style: TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}