import 'package:flutter/material.dart';
import '../Model/Launch.dart';
import '../Model/LaunchPad.dart';
import '../Model/Payload.dart';
import '../Model/Rocket.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class RocketLaunchDetailsScreen extends StatefulWidget {
  static const routeName = '/launch-details';
  @override
  _RocketLaunchDetailsScreenState createState() =>
      _RocketLaunchDetailsScreenState();
}

class _RocketLaunchDetailsScreenState extends State<RocketLaunchDetailsScreen> {
  bool isLoading = false;
  LaunchPad launchPadDetails;
  Rocket rocketDetails;
  Launch launchDetails;
  Payload payloadDetails;
  String error = "";
  var dio = Dio();
  void toggleIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future getLaunchInfo(touchpad) async {
    toggleIsLoading();
    try {
      String url = "https://api.spacexdata.com/v4/launchpads/${touchpad}";
      Response response = await dio.get(url);
      setState(() {
        launchPadDetails = new LaunchPad(
          response.data['details'],
          response.data['region'],
          response.data['full_name'],
          response.data['launch_successes'],
          response.data['launch_attempts'],
        );
        toggleIsLoading();
      });
    } catch (err) {
      toggleIsLoading();
      setState(() {
        error = "An Error Happened";
      });
    }
  }

  Future getRocketInfo(rocket) async {
    toggleIsLoading();

    String url = "https://api.spacexdata.com/v4/rockets/${rocket}";
    try {
      Response response = await dio.get(url);
      setState(() {
        rocketDetails = new Rocket(
          response.data['height']['meters'],
          response.data['diameter']['meters'],
          response.data['mass']['kg'],
          response.data['name'],
          response.data['active'],
          response.data['stages'],
        );
        toggleIsLoading();
      });
    } catch (err) {
      toggleIsLoading();
      setState(() {
        error = "An Error Happened";
      });
    }
  }

  Future getPayLoadInfo(payload) async {
    toggleIsLoading();

    String url = "https://api.spacexdata.com/v4/payloads/${payload}";
    try {
      Response response = await dio.get(url);
      setState(() {
        payloadDetails = new Payload(response.data['name'],
            response.data['type'], response.data['reused']);
        toggleIsLoading();
      });
    } catch (err) {
      toggleIsLoading();
      setState(() {
        error = "An Error Happened";
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      launchDetails = ModalRoute.of(context).settings.arguments;
      await getRocketInfo(launchDetails.rocket);
      await getLaunchInfo(launchDetails.launchpad);
      await getPayLoadInfo(launchDetails.payloads[0]);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(launchDetails == null ? "" : launchDetails.name),
      ),
      body: isLoading || launchDetails == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          margin: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Text(
                "Launch Details",
                style:
                TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              ListTile(
                  trailing: InkWell(
                    onTap: () async {
                      print(
                          "https://www.youtube.com/watch?v=${launchDetails.youtubeID}");
                      try {
                        await launch(
                            "https://www.youtube.com/watch?v=${launchDetails.youtubeID}");
                      } catch (err) {
                        print(err);
                      }
                    },
                    child: launchDetails.youtubeID == null
                        ? SizedBox()
                        : FaIcon(
                      FontAwesomeIcons.youtube,
                      color: Colors.red,
                    ),
                  ),
                  leading: (launchDetails.success == null)
                      ? Icon(
                    Icons.info,
                    color: Colors.orange,
                  )
                      : (launchDetails.success)
                      ? Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                  )
                      : FaIcon(
                    FontAwesomeIcons.solidTimesCircle,
                    color: Colors.red,
                  ),
                  title: Text(
                    launchDetails.name,
                    style: TextStyle(fontSize: 17, color: Colors.teal),
                  ),
                  subtitle: Text(
                    DateFormat.yMMMd().format(
                        DateTime.fromMillisecondsSinceEpoch(
                            launchDetails.timestamp * 1000)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
              Divider(),
              Text(
                "Launch Pad",
                style:
                TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Text(
                launchPadDetails.fullName,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              Container(
                margin: EdgeInsets.only(top: 5, bottom: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        color: Colors.teal,
                      ),
                      Text(
                        launchPadDetails.region,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                launchPadDetails.details,
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
              Divider(),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  "Rocket Details",
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${rocketDetails.name}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    "Height ${rocketDetails.height} meters",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    "Diameter ${rocketDetails.diameter} meters",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    "Mass ${rocketDetails.mass} kg",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Row(
                    children: [
                      rocketDetails.active
                          ? Text("Currently Active",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green))
                          : Text(
                        "Currently Inactive",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ],
                  )
                ],
              ),
              Divider(),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(
                  "Payload",
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${payloadDetails.name}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Text(
                    "${payloadDetails.type}",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                  Row(
                    children: [
                      rocketDetails.active
                          ? Text("Reusable",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.green))
                          : Text(
                        "Unreusable",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}