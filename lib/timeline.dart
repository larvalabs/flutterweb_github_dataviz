import 'package:flutter_web.examples.github_dataviz/constants.dart';
import 'package:flutter_web.examples.github_dataviz/data/contribution_data.dart';
import 'package:flutter_web.examples.github_dataviz/data/week_label.dart';
import 'package:flutter_web/material.dart';

class Timeline extends StatefulWidget {
  int numWeeks;
  double animationValue;
  List<WeekLabel> weekLabels;
  
  Timeline(this.numWeeks, this.animationValue, this.weekLabels);

  @override
  State<StatefulWidget> createState() {
    return new TimelineState();
  }
}

class TimelineState extends State<Timeline> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new CustomPaint(
            foregroundPainter: new TimelinePainter(widget.numWeeks, widget.animationValue, widget.weekLabels),
            child: new Container(height: 200,))
    );
  }
}

class TimelinePainter extends CustomPainter {

  Paint mainLinePaint;
  Paint milestoneLinePaint;

  Color lineColor = Colors.white;

  int numWeeks;
  double animationValue;
  int weekYearOffset = 9; // Week 0 in our data is 9 weeks before the year boundary (i.e. week 43)

  List<WeekLabel> weekLabels;

  int yearNumber = 2015;

  TimelinePainter(this.numWeeks, this.animationValue, this.weekLabels) {
    mainLinePaint = new Paint();
    mainLinePaint.style = PaintingStyle.stroke;
    mainLinePaint.color = Constants.timelineLineColor;
    milestoneLinePaint = new Paint();
    milestoneLinePaint.style = PaintingStyle.stroke;
    milestoneLinePaint.color = Constants.milestoneColor;
  }

  @override
  void paint(Canvas canvas, Size size) {

    double labelHeight = 20;
    double labelHeightDoubled = labelHeight*2;

    double mainLineY = size.height/2;
    canvas.drawLine(new Offset(0, mainLineY), new Offset(size.width, mainLineY), mainLinePaint);

    {
      double currWeekX = size.width * animationValue;
      canvas.drawLine(new Offset(currWeekX, labelHeightDoubled), new Offset(currWeekX, size.height - labelHeightDoubled), mainLinePaint);
    }
    
    {
      for (int week=0; week<numWeeks; week++) {
        double lineHeight = size.height/32;
        bool isYear = false;
        if ((week - 9) % 52 == 0) {
          // Year
          isYear = true;
          lineHeight = size.height/2;
        } else if ((week - 1) % 4 == 0) {
          // Month
          lineHeight = size.height/8;
        }

        double currX = (week / numWeeks.toDouble()) * size.width;
        if (lineHeight > 0) {
          double margin = (size.height - lineHeight) / 2;
          canvas.drawLine(new Offset(currX, margin), new Offset(currX, size.height - margin), mainLinePaint);
        }

        if (isYear) {
          TextSpan span = new TextSpan(style: new TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12), text: "${yearNumber}");
          TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
          tp.layout();
          tp.paint(canvas, new Offset(currX, size.height - labelHeight));
          yearNumber++;
        }
      }
    }
    
    {
      for (int i = 0; i<weekLabels.length; i++) {
        WeekLabel weekLabel = weekLabels[i];
        double currX = (weekLabel.weekNum / numWeeks.toDouble()) * size.width;
        double lineHeight = size.height/2;
        double margin = (size.height - lineHeight) / 2;
        canvas.drawLine(new Offset(currX, margin), new Offset(currX, size.height - margin), milestoneLinePaint);

        TextSpan span = new TextSpan(style: new TextStyle(color: Constants.milestoneColor, fontSize: 12), text: weekLabel.label);
        TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, new Offset(currX, size.height - labelHeightDoubled));

      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }


}