import 'package:flutter_web.examples.github_dataviz/data/contribution_data.dart';
import 'package:flutter_web/material.dart';

class Timeline extends StatefulWidget {
  List<ContributionData> contributions;

  Timeline(this.contributions);

  @override
  State<StatefulWidget> createState() {
    return new TimelineState();
  }
}

class TimelineState extends State<Timeline> {
  @override
  Widget build(BuildContext context) {
    var totalLoaded = widget.contributions != null ? widget.contributions.length : 0;
    return new Text("Weeks loaded: ${totalLoaded}");
  }
}