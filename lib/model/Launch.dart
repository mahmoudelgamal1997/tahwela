class Launch {
  String id;
  String name;
  int timestamp;
  String launchpad;
  String youtubeID;
  List<dynamic> payloads;
  String rocket;
  bool success;
  Launch(this.id, this.name, this.timestamp, this.launchpad, this.youtubeID,
      this.payloads, this.rocket, this.success);
}