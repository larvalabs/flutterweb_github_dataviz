import 'dart:math';

import 'package:flutter_web.examples.github_dataviz/catmull.dart';
import 'package:flutter_web.examples.github_dataviz/data/data_series.dart';
import 'package:flutter_web.examples.github_dataviz/mathutils.dart';
import 'package:flutter_web/material.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/painting.dart';

class LayeredChart extends StatefulWidget {
  List<DataSeries> dataToPlot;
  double animationValue;

  static EarlyInterpolator interpolator = new EarlyInterpolator(0.8);

  LayeredChart(this.dataToPlot, animationValue) {
    this.animationValue = interpolator.get(animationValue);
  }

  @override
  State<StatefulWidget> createState() {
    return new LayeredChartState();
  }
}

class LayeredChartState extends State<LayeredChart> {
  @override
  Widget build(BuildContext context) {
    return new Container(
        color: const Color(0xFF000020),
        child: new CustomPaint(foregroundPainter: new ChartPainter(widget.dataToPlot, 80, 200, 110, 10, 50, 5, 750, widget.animationValue), child: new Container()));
  }
}

class ChartPainter extends CustomPainter {
  List<DataSeries> dataToPlot;
  double margin;
  double graphHeight;
  double graphGap;
  double theta;
  double capTheta;
  double capSize;
  int numPoints;
  double amount = 1.0;

  List<double> curvePoints;

  ChartPainter(
      List<DataSeries> dataToPlot, double margin, double graphHeight, double graphGap, double degrees, double capDegrees, double capSize, int numPoints, double amount) {
    this.dataToPlot = dataToPlot;
    this.margin = margin;
    this.graphHeight = graphHeight;
    this.graphGap = graphGap;
    this.theta = pi * degrees / 180;
    this.capTheta = pi * capDegrees / 180;
    this.capSize = capSize;
    this.numPoints = numPoints;
    this.amount = amount;
    curvePoints = new List<double>(numPoints);
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint pathPaint = new Paint();
    pathPaint.style = PaintingStyle.fill;
    Paint capPaint = new Paint();
    capPaint.style = PaintingStyle.fill;
    Paint textPaint = new Paint();
    textPaint.color = new Color(0xFFFFFFFF);
//    print("PAINTING");
    if (dataToPlot.length == 0) {
      return;
    }
    /*
    List<Color> colors = [
      new Color(0x80c58fc4),
      new Color(0x80348c9a),
      new Color(0x8072c785),
      new Color(0x80bec271),
    ];
    */
    // Using the 900 version of the Material color for the main color, and the 500 version for the cap
    List<Color> colors = [
      Colors.red[900],
      new Color(0xffc4721a),
      Colors.lime[900],
      Colors.green[900],
      Colors.blue[900],
      Colors.purple[900],
    ];
    List<Color> capColors = [
      Colors.red[500],
      Colors.amber[500],
      Colors.lime[500],
      Colors.green[500],
      Colors.blue[500],
      Colors.purple[500],
    ];
    int m = dataToPlot.length;
    // How far along to draw
    double totalGap = m * graphGap;
    double xIndent = totalGap / tan(capTheta);
    double dx = xIndent / (m - 1);
    double startX = margin + xIndent;
    double endX = size.width - margin;
    double startY = size.height - margin;
    double endY = size.height - margin - (endX - startX) * tan(theta);
    double capX = cos(capTheta + pi / 2) * capSize * 2;
    double capY = -sin(capTheta + pi / 2) * capSize * 2;
//    TextStyle textStyle = new TextStyle();
//    ParagraphBuilder paragraphBuilder = new ParagraphBuilder(new ParagraphStyle(fontSize: 10));

    // paragraphBuilder.pushStyle(new TextStyle);
//    paragraphBuilder.addText("LINES COMMITTED");
//    Paragraph paragraph = paragraphBuilder.build();
    for (int j = m - 1; j >= 0; j--) {
      DataSeries data = dataToPlot[j];
      int n = data.series.length;
      int maxValue = 0;
      double maxCap = 0;
      List<Point2D> controlPoints = new List<Point2D>();
      controlPoints.add(new Point2D(-1, 0));
      double last = 0;
      for (int i = 0; i < n; i++) {
        if (data.series[i] > maxValue) {
          maxValue = data.series[i];
        }
        double v = data.series[i].toDouble();
        controlPoints.add(new Point2D(i.toDouble(), v));
        last = v;
      }
      controlPoints.add(new Point2D(n.toDouble(), last));
      CatmullInterpolator curve = new CatmullInterpolator(controlPoints);
      canvas.save();
      canvas.translate(-dx * j, -graphGap * j);
//      canvas.drawParagraph(paragraph, new Offset(startX, startY + 5));

      {
        canvas.save();
        // Flat approach
        double textPosition = 0.2;
        double textX = MathUtils.map(textPosition, 0, 1, startX, endX);
        double textY = MathUtils.map(textPosition, 0, 1, startY, endY) + 5;
        canvas.translate(textX, textY);
        double scale = 0.67;
//        canvas.scale(1, scale);
//        canvas.skew(capTheta, -theta * 1.4);
        canvas.skew(capTheta * 1.0, -theta);
//        canvas.skew(capTheta, -theta);
        // Vertical approach
//        canvas.translate(startX + 25, startY - 2);
//        canvas.skew(0 * pi / 180, -theta);
        TextSpan span = new TextSpan(style: new TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12), text: data.label.toUpperCase());
        TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
        tp.layout();
        tp.paint(canvas, new Offset(0, 0));
        canvas.restore();
      }
      // Build list of points
      ControlPointAndValue cpv = new ControlPointAndValue();
      for (int i = 0; i < numPoints; i++) {
        cpv.value = MathUtils.map(i.toDouble(), 0, (numPoints - 1).toDouble(), 0, (n - 1).toDouble());
        curve.progressiveGet(cpv);
        curvePoints[i] = MathUtils.map(max(0, cpv.value), 0, maxValue.toDouble(), 0, graphHeight);
      }

      pathPaint.color = colors[j];
      capPaint.color = capColors[j];
      Path path = new Path();
      Path capPath = new Path();
      int k = (numPoints * amount).toInt();
//      path.moveTo(startX, startY);
//      capPath.moveTo(startX + capX, startY + capY);
      double capRange = capSize / cos(capTheta);
      double xWidth = (endX - startX) / numPoints;
      double tanCapTheta = tan(capTheta);
      int offset = numPoints - k;
      for (int i = 0; i < k; i++) {
        double v = curvePoints[i];
        int j = i + 1;
        double xDist = xWidth;
        double capV = v;
        while (j < numPoints && xDist < capRange) {
          double cy = curvePoints[j] + xDist * tanCapTheta;
          capV = max(capV, cy);
          j++;
          xDist += xWidth;
        }
        double inX = (i + offset).toDouble();
        double x = MathUtils.map(inX, 0, (numPoints - 1).toDouble(), startX, endX);
        double baseY = MathUtils.map(inX, 0, (numPoints - 1).toDouble(), startY, endY);
        if (i == 0) {
          path.moveTo(x, baseY);
          capPath.moveTo(x, baseY);
          capPath.lineTo(x + capX, baseY + capY);
        }
        double y = baseY - v;
        double cY = baseY - capV;
        path.lineTo(x, y);
        capPath.lineTo(x, cY);
      }
      /*
      for (int i = numPoints - 1; i >= 0; i--) {
        double input = MathUtils.map(
            i.toDouble(), 0, numPoints.toDouble(), 0, n.toDouble());
        double v = max(0, curve.get(input));
        double x = MathUtils.map(
            i.toDouble(), 0, (numPoints - 1).toDouble(), startX, endX);
        double baseY = MathUtils.map(
            i.toDouble(), 0, (numPoints - 1).toDouble(), startY, endY);
        double y = baseY -
            MathUtils.map(v, 0, maxValue.toDouble(), 0, graphHeight);
        capPath.lineTo(x, y);
      }
      */
      path.lineTo(endX, endY);
      path.lineTo(endX, endY + 1);
      path.lineTo(startX, startY + 1);
      path.close();
      capPath.lineTo(endX, endY);
      capPath.lineTo(endX, endY + 1);
      capPath.lineTo(startX, startY + 1);
      capPath.close();
      canvas.drawPath(capPath, capPaint);
      canvas.drawPath(path, pathPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
