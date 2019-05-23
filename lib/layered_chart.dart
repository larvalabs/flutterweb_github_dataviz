import 'dart:math';

import 'package:flutter_web.examples.github_dataviz/catmull.dart';
import 'package:flutter_web.examples.github_dataviz/constants.dart';
import 'package:flutter_web.examples.github_dataviz/data/data_series.dart';
import 'package:flutter_web.examples.github_dataviz/data/week_label.dart';
import 'package:flutter_web.examples.github_dataviz/mathutils.dart';
import 'package:flutter_web/material.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/painting.dart';

/// A widget that draws a series of filled charts layered next to, or on top of each other.
/// The widget will adjust it's draw angle based on screen size ratio to better handle landscape and
/// portrait orientations.
class LayeredChart extends StatefulWidget {
  List<DataSeries> dataToPlot;
  List<WeekLabel> milestones;
  double animationValue;

  LayeredChart(this.dataToPlot, this.milestones, animationValue) {
    this.animationValue = animationValue;
  }

  @override
  State<StatefulWidget> createState() {
    return new LayeredChartState();
  }
}

class DrawCache {
  List<Path> paths;
  List<Path> capPaths;
  List<double> maxValues;
  double theta;
  double graphHeight;
  List<TextPainter> labelPainter;
  List<TextPainter> milestonePainter;
  Size lastSize = null;

  void buildCache(Size size, List<DataSeries> dataToPlot, List<WeekLabel> milestones, int numPoints, double graphGap,
      double margin, double capTheta, double capSize) {
    double screenRatio = size.width / size.height;
    double degrees = MathUtils.clampedMap(screenRatio, 0.5, 2.5, 50, 5);
    theta = pi * degrees / 180;
    graphHeight = MathUtils.clampedMap(screenRatio, 0.5, 2.5, 50, 150);

    int m = dataToPlot.length;
    paths = new List<Path>(m);
    capPaths = new List<Path>(m);
    maxValues = new List<double>(m);
    for (int i = 0; i < m; i++) {
      int n = dataToPlot[i].series.length;
      maxValues[i] = 0;
      for (int j = 0; j < n; j++) {
        double v = dataToPlot[i].series[j].toDouble();
        if (v > maxValues[i]) {
          maxValues[i] = v;
        }
      }
    }
    double totalGap = m * graphGap;
    double xIndent = totalGap / tan(capTheta);
    double startX = margin + xIndent;
    double endX = size.width - margin;
    double startY = size.height;
    double endY = startY - (endX - startX) * tan(theta);
    double xWidth = (endX - startX) / numPoints;
    double capRangeX = capSize * cos(capTheta);
    double tanCapTheta = tan(capTheta);
    List<double> curvePoints = new List<double>(numPoints);
    for (int i = 0; i < m; i++) {
      List<int> series = dataToPlot[i].series;
      int n = series.length;
      List<Point2D> controlPoints = new List<Point2D>();
      controlPoints.add(new Point2D(-1, 0));
      double last = 0;
      for (int j = 0; j < n; j++) {
        double v = series[j].toDouble();
        controlPoints.add(new Point2D(j.toDouble(), v));
        last = v;
      }
      controlPoints.add(new Point2D(n.toDouble(), last));
      CatmullInterpolator curve = new CatmullInterpolator(controlPoints);
      ControlPointAndValue cpv = new ControlPointAndValue();
      for (int j = 0; j < numPoints; j++) {
        cpv.value = MathUtils.map(j.toDouble(), 0, (numPoints - 1).toDouble(), 0, (n - 1).toDouble());
        curve.progressiveGet(cpv);
        curvePoints[j] = MathUtils.map(max(0, cpv.value), 0, maxValues[i].toDouble(), 0, graphHeight);
      }
      paths[i] = new Path();
      capPaths[i] = new Path();
      paths[i].moveTo(startX, startY);
      capPaths[i].moveTo(startX, startY);
      for (int j = 0; j < numPoints; j++) {
        double v = curvePoints[j];
        int k = j + 1;
        double xDist = xWidth;
        double capV = v;
        while (k < numPoints && xDist <= capRangeX) {
          double cy = curvePoints[k] + xDist * tanCapTheta;
          capV = max(capV, cy);
          k++;
          xDist += xWidth;
        }
        double x = MathUtils.map(j.toDouble(), 0, (numPoints - 1).toDouble(), startX, endX);
        double baseY = MathUtils.map(j.toDouble(), 0, (numPoints - 1).toDouble(), startY, endY);
        double y = baseY - v;
        double cY = baseY - capV;
        paths[i].lineTo(x, y);
        if (j == 0) {
          int k = capRangeX ~/ xWidth;
          double mx = MathUtils.map(-k.toDouble(), 0, (numPoints - 1).toDouble(), startX, endX);
          double my = MathUtils.map(-k.toDouble(), 0, (numPoints - 1).toDouble(), startY, endY) - capV;
          capPaths[i].lineTo(mx, my);
        }
        capPaths[i].lineTo(x, cY);
      }
      paths[i].lineTo(endX, endY);
      paths[i].lineTo(endX, endY + 1);
      paths[i].lineTo(startX, startY + 1);
      paths[i].close();
      capPaths[i].lineTo(endX, endY);
      capPaths[i].lineTo(endX, endY + 1);
      capPaths[i].lineTo(startX, startY + 1);
      capPaths[i].close();
    }
    labelPainter = new List<TextPainter>();
    for (int i = 0; i < dataToPlot.length; i++) {
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 12),
          text: dataToPlot[i].label.toUpperCase());
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      tp.layout();
      labelPainter.add(tp);
    }
    milestonePainter = new List<TextPainter>();
    for (int i = 0; i < milestones.length; i++) {
      TextSpan span = new TextSpan(
          style: new TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 10),
          text: milestones[i].label.toUpperCase());
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      tp.layout();
      milestonePainter.add(tp);
    }
    lastSize = new Size(size.width, size.height);
  }
}

class LayeredChartState extends State<LayeredChart> {
  DrawCache drawCache = new DrawCache();

  @override
  Widget build(BuildContext context) {
    return new Container(
        color: Constants.backgroundColor,
        child: new CustomPaint(
            foregroundPainter: new ChartPainter(
                drawCache: drawCache,
                dataToPlot: widget.dataToPlot,
                milestones: widget.milestones,
                margin: 80,
                graphGap: 50,
                capDegrees: 50,
                capSize: 12,
                numPoints: 500,
                amount: widget.animationValue),
            child: new Container()));
  }
}

class ChartPainter extends CustomPainter {
  static List<Color> colors = [
    Colors.red[900],
    new Color(0xffc4721a),
    Colors.lime[900],
    Colors.green[900],
    Colors.blue[900],
    Colors.purple[900],
  ];
  static List<Color> capColors = [
    Colors.red[500],
    Colors.amber[500],
    Colors.lime[500],
    Colors.green[500],
    Colors.blue[500],
    Colors.purple[500],
  ];

  List<DataSeries> dataToPlot;
  List<WeekLabel> milestones;

  double margin;
  double graphGap;
  double capTheta;
  double capSize;
  int numPoints;
  double amount = 1.0;

  Paint pathPaint;
  Paint capPaint;
  Paint textPaint;
  Paint milestonePaint;
  Paint linePaint;
  Paint fillPaint;

  DrawCache drawCache;

  ChartPainter({
    this.drawCache,
    this.dataToPlot,
    this.milestones,
    this.margin,
    this.graphGap,
    double capDegrees,
    this.capSize,
    this.numPoints,
    this.amount,
  }) {
    this.capTheta = pi * capDegrees / 180;
    pathPaint = new Paint();
    pathPaint.style = PaintingStyle.fill;
    capPaint = new Paint();
    capPaint.style = PaintingStyle.fill;
    textPaint = new Paint();
    textPaint.color = new Color(0xFFFFFFFF);
    milestonePaint = new Paint();
    milestonePaint.color = Constants.milestoneColor;
    milestonePaint.style = PaintingStyle.stroke;
    milestonePaint.strokeWidth = 2;
    linePaint = new Paint();
    linePaint.style = PaintingStyle.stroke;
    linePaint.strokeWidth = 0.5;
    fillPaint = new Paint();
    fillPaint.style = PaintingStyle.fill;
    fillPaint.color = new Color(0xFF000000);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (dataToPlot.length == 0) {
      return;
    }

    if (drawCache.lastSize == null ||
        size.width != drawCache.lastSize.width ||
        size.height != drawCache.lastSize.height) {
      print("Building paths, lastsize = ${drawCache.lastSize}");
      drawCache.buildCache(size, dataToPlot, milestones, numPoints, graphGap, margin, capTheta, capSize);
    }

    int m = dataToPlot.length;
    int numWeeks = dataToPlot[0].series.length;
    // How far along to draw
    double totalGap = m * graphGap;
    double xIndent = totalGap / tan(capTheta);
    double dx = xIndent / (m - 1);
    double startX = margin + xIndent;
    double endX = size.width - margin;
    double startY = size.height;
    double endY = startY - (endX - startX) * tan(drawCache.theta);
    // MILESTONES
    {
      for (int i = 0; i < milestones.length; i++) {
        WeekLabel milestone = milestones[i];
        double p = (milestone.weekNum.toDouble() / numWeeks) + (1 - amount);
        if (p < 1) {
          double x1 = MathUtils.map(p, 0, 1, startX, endX);
          double y1 = MathUtils.map(p, 0, 1, startY, endY);
          double x2 = x1 - xIndent;
          double y2 = y1 - graphGap * (m - 1);
          x1 += dx * 0.5;
          y1 += graphGap * 0.5;
          double textY = y1 + 5;
          double textX = x1 + 5 * tan(capTheta);
          canvas.drawLine(new Offset(x1, y1), new Offset(x2, y2), milestonePaint);
          canvas.save();
          TextPainter tp = drawCache.milestonePainter[i];
          canvas.translate(textX, textY);
          canvas.skew(tan(capTheta * 1.0), -tan(drawCache.theta));
          canvas.translate(-tp.width / 2, 0);
          tp.paint(canvas, new Offset(0, 0));
          canvas.restore();
        }
      }
    }
    for (int i = m - 1; i >= 0; i--) {
      canvas.save();
      canvas.translate(-dx * i, -graphGap * i);

      {
        // TEXT LABELS
        canvas.save();
        double textPosition = 0.2;
        double textX = MathUtils.map(textPosition, 0, 1, startX, endX);
        double textY = MathUtils.map(textPosition, 0, 1, startY, endY) + 5;
        canvas.translate(textX, textY);
        TextPainter tp = drawCache.labelPainter[i];
        canvas.skew(0, -tan(drawCache.theta));
        canvas.drawRect(new Rect.fromLTWH(-1, -1, tp.width + 2, tp.height + 2), fillPaint);
        tp.paint(canvas, new Offset(0, 0));
        canvas.restore();
      }

      linePaint.color = capColors[i];
      canvas.drawLine(new Offset(startX, startY), new Offset(endX, endY), linePaint);

      Path clipPath = new Path();
      clipPath.moveTo(startX - capSize, startY + 11);
      clipPath.lineTo(endX, endY + 1);
      clipPath.lineTo(endX, endY - drawCache.graphHeight - capSize);
      clipPath.lineTo(startX - capSize, startY - drawCache.graphHeight - capSize);
      clipPath.close();
      canvas.clipPath(clipPath);

      pathPaint.color = colors[i];
      capPaint.color = capColors[i];
      double offsetX = MathUtils.map(1 - amount, 0, 1, startX, endX);
      double offsetY = MathUtils.map(1 - amount, 0, 1, startY, endY);
      canvas.translate(offsetX - startX, offsetY - startY);
      canvas.drawPath(drawCache.capPaths[i], capPaint);
      canvas.drawPath(drawCache.paths[i], pathPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
