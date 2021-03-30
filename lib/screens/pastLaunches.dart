import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Model/Launch.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rounded_date_picker/rounded_picker.dart';

class PastLaunchesScreen extends StatefulWidget {
  @override
  _PastLaunchesScreenState createState() => _PastLaunchesScreenState();
}

class _PastLaunchesScreenState extends State<PastLaunchesScreen> {
  List<Launch> launches = [];
  bool isLoading = false;
  List<Launch> filteredLaunches = [];
  String error = "";
  var from;
  var to;
  void toggleIsLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void filterLaunches() {
    filteredLaunches = launches;
    if (from != null) {
      filteredLaunches = filteredLaunches
          .where((element) => element.timestamp * 1000 > from)
          .toList();
      print(filteredLaunches.length);
    }
    if (to != null) {
      filteredLaunches = filteredLaunches
          .where((element) => element.timestamp * 1000 < to)
          .toList();
    }
    if (from == null && to == null) {
      filteredLaunches = launches;
    }
  }

  void filterDate() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            margin: EdgeInsets.all(10),
            height: 150,
            child: Column(
              children: [
                Text(
                  "Filter by date",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FlatButton(
                      onPressed: () async {
                        DateTime newDateTime = await showRoundedDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(DateTime.now().year - 20),
                            lastDate: DateTime(DateTime.now().year + 1),
                            borderRadius: 25,
                            background: Colors.grey[100].withOpacity(0.8),
                            theme: ThemeData(primarySwatch: Colors.teal),
                            height: 200);
                        setState(() {
                          from = new DateTime(newDateTime.year,
                              newDateTime.month, newDateTime.day)
                              .millisecondsSinceEpoch;
                        });
                        filterLaunches();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "From",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                    ),
                    FlatButton(
                      onPressed: () async {
                        DateTime newDateTime = await showRoundedDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(DateTime.now().year - 20),
                            lastDate: DateTime(DateTime.now().year + 1),
                            borderRadius: 25,
                            background: Colors.grey[100].withOpacity(0.8),
                            theme: ThemeData(primarySwatch: Colors.teal),
                            height: 200);
                        setState(() {
                          to = new DateTime(newDateTime.year, newDateTime.month,
                              newDateTime.day)
                              .millisecondsSinceEpoch;
                        });
                        filterLaunches();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "To",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      from != null || to != null
                          ? Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.green,
                      )
                          : SizedBox(),
                      from == null
                          ? SizedBox()
                          : Text(
                        "* From  ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(from))}",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                      to == null
                          ? SizedBox()
                          : Text(
                        " To ${DateFormat.yMMMd().format(DateTime.fromMillisecondsSinceEpoch(to))}",
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                from != null || to != null
                    ? FlatButton(
                    onPressed: () {
                      setState(() {
                        to = null;
                        from = null;
                      });
                      filterLaunches();
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Text(
                          "Clear Filter",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          Icons.delete,
                          color: Colors.red,
                        )
                      ],
                    ))
                    : SizedBox()
              ],
            ),
          );
        });
  }

  void getRocketLaunches() async {
    toggleIsLoading();
    String url = "https://api.spacexdata.com/v4/launches";
    var dio = Dio();
    try {
      Response response = await dio.get(url);
      for (int i = 0; i < response.data.length; i++) {
        if (DateTime.now().millisecondsSinceEpoch >
            response.data[i]['date_unix'] * 1000) {
          launches.add(new Launch(
              response.data[i]['id'],
              response.data[i]['name'],
              response.data[i]['date_unix'],
              response.data[i]['launchpad'],
              response.data[i]['links']['youtube_id'],
              response.data[i]['payloads'],
              response.data[i]['rocket'],
              response.data[i]['success']));
        }
      }
      launches = launches.reversed.toList();
      filteredLaunches = launches;
      toggleIsLoading();
    } catch (err) {
      toggleIsLoading();
      setState(() {
        error = "An Error Happened";
      });
    }
  }

  void initState() {
    // TODO: implement initState
    getRocketLaunches();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  "The past rocket launches",
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredLaunches.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 2,
                          child: Container(
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: ListTile(
                                onTap: () => Navigator.of(context)
                                    .pushNamed('/launch-details',
                                    arguments:
                                    filteredLaunches[index]),
                                trailing: (filteredLaunches[index]
                                    .success ==
                                    null)
                                    ? Icon(
                                  Icons.info,
                                  color: Colors.orange,
                                )
                                    : (filteredLaunches[index].success)
                                    ? Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                )
                                    : FaIcon(
                                  FontAwesomeIcons
                                      .solidTimesCircle,
                                  color: Colors.red,
                                ),
                                title: Text(
                                  filteredLaunches[index].name,
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.teal),
                                ),
                                subtitle: Text(
                                  DateFormat.yMMMd().format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          filteredLaunches[index]
                                              .timestamp *
                                              1000)),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )),
                          ),
                          //launches[index].timestamp.toString()),
                        );
                      }),
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_alt_sharp),
        onPressed: filterDate,
      ),
    );
  }
}