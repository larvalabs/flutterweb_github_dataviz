// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'dart:convert';
import 'dart:html';

import 'package:flutter_web.examples.github_dataviz/data/contribution_data.dart';
import 'package:flutter_web.examples.github_dataviz/data/stat_for_week.dart';
import 'package:flutter_web.examples.github_dataviz/data/user_contribution.dart';
import 'package:flutter_web.examples.github_dataviz/layered_chart.dart';
import 'package:flutter_web.examples.github_dataviz/timeline.dart';
import 'package:flutter_web/io.dart';
import 'package:flutter_web/material.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => new _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {

  AnimationController _animation;
  List<UserContribution> contributions;
  List<StatForWeek> starsByWeek;
  List<StatForWeek> forksByWeek;

  @override
  void initState() {
    super.initState();
    // We use 3600 milliseconds instead of 1800 milliseconds because 0.0 -> 1.0
    // represents an entire turn of the square whereas in the other examples
    // we used 0.0 -> math.pi, which is only half a turn.
    _animation = new AnimationController(
      duration: const Duration(milliseconds: 3600),
      vsync: this,
    )..repeat();

    loadGitHubData();
  }

  @override
  Widget build(BuildContext context) {
    var greenSquare = new Container(
      width: 200.0,
      height: 200.0,
      color: const Color(0xFF00FF00),
    );

    // Combined contributions data
    List<List<int>> dataToPlot = new List();
    if (contributions != null) {
      List<int> series = new List();
      for (UserContribution userContrib in contributions) {
        for (int i=0; i<userContrib.contributions.length; i++) {
          ContributionData data = userContrib.contributions[i];
          if (series.length > i) {
            series[i] = series[i] + data.add;
          } else {
            series.add(data.add);
          }
        }
      }
      dataToPlot.add(series);
    }

    // Stars by week
    if (starsByWeek != null) {
      List<int> series = new List();
      starsByWeek.forEach((e) => series.add(e.stat));
      dataToPlot.add(series);
    }

    // Forks by week
    if (forksByWeek != null) {
      List<int> series = new List();
      forksByWeek.forEach((e) => series.add(e.stat));
      dataToPlot.add(series);
    }

    LayeredChart layeredChart = new LayeredChart(dataToPlot);

    List<ContributionData> timelineData = new List<ContributionData>();
    if (contributions != null) {
      timelineData = contributions[0].contributions;
    }
    Timeline timeline = new Timeline(timelineData);

    Column mainColumn = new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        new Expanded(child: layeredChart),
        timeline,
      ],
    );

    return new Directionality(
        textDirection: TextDirection.ltr,
        child: mainColumn
    );
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  Future loadGitHubData() async {
    String contributorsJsonStr = await HttpRequest.getString("/github_data/contributors.json");
    print("Loaded contributors json file:\n${contributorsJsonStr.substring(0, 100)}...");
    List jsonObjs = jsonDecode(contributorsJsonStr) as List;
    print("Loaded ${jsonObjs.length} JSON objects.");
    List<UserContribution> contributionList = jsonObjs.map((e) => UserContribution.fromJson(e)).toList();
    print("Loaded ${contributionList.length} code contributions to /flutter/flutter repo.");

    int numWeeksTotal = contributionList[0].contributions.length;

    String starsByWeekStr = await HttpRequest.getString("/github_data/stars.tsv");
    List<StatForWeek> starsByWeekLoaded = summarizeWeeksFromTSV(starsByWeekStr, numWeeksTotal);

    String forksByWeekStr = await HttpRequest.getString("/github_data/forks.tsv");
    List<StatForWeek> forksByWeekLoaded = summarizeWeeksFromTSV(forksByWeekStr, numWeeksTotal);

    setState(() {
      this.contributions = contributionList;
      this.starsByWeek = starsByWeekLoaded;
      this.forksByWeek = forksByWeekLoaded;
    });
  }

  List<StatForWeek> summarizeWeeksFromTSV(String starsByWeekStr, int numWeeksTotal) {
    List<StatForWeek> loadedStats = new List();
    HashMap<int, StatForWeek> starsWeekMap = new HashMap();
    starsByWeekStr.split("\n").forEach((s) {
      print("Parsing ${s}");
      List<String> split = s.split("\t");
      if (split.length == 2) {
        int weekNum = int.parse(split[0]);
        starsWeekMap[weekNum] = new StatForWeek(weekNum, int.parse(split[1]));
      }
    });
    print("Laoded ${starsWeekMap.length} star totals for weeks.");
    // Convert into a list by week, but fill in empty weeks with 0
    for (int i=0; i<numWeeksTotal; i++) {
      StatForWeek starsForWeek = starsWeekMap[i];
      if (starsForWeek == null) {
        loadedStats.add(new StatForWeek(i, 0));
      } else {
        loadedStats.add(starsForWeek);
      }
    }
    return loadedStats;
  }
}

void main() {
  runApp(new Center(child: new MainLayout()));
}
