import 'dart:math';

import 'package:flutter_web.examples.github_dataviz/mathutils.dart';
import 'package:flutter_web/widgets.dart';

class LayeredChart extends StatefulWidget {
  List<List<int>> dataToPlot;

  LayeredChart(this.dataToPlot);

  @override
  State<StatefulWidget> createState() {
    return new LayeredChartState();
  }
}

class LayeredChartState extends State<LayeredChart> {
  @override
  Widget build(BuildContext context) {
    // access plot data
    widget.dataToPlot;

    return new Container(
      color: const Color(0xFF000000),
      child: new CustomPaint(size: new Size(800, 800), foregroundPainter: new ChartPainter(widget.dataToPlot, 40, 80, 10, 6))
    );
  }
}

class ChartPainter extends CustomPainter {

  List<List<int>> dataToPlot;
  double margin;
  double graphHeight;
  double theta;
  double capSize;

  ChartPainter(List<List<int>> dataToPlot, double margin, double graphHeight, double degrees, double capSize) {
    this.dataToPlot = dataToPlot;
    this.margin = margin;
    this.graphHeight = graphHeight;
    this.theta = pi * degrees / 180;
    this.capSize = capSize;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint pathPaint = new Paint();
    pathPaint.color = new Color(0x80c58fc4);
    pathPaint.style = PaintingStyle.fill;
    Paint capPaint = new Paint();
    capPaint.color = new Color(0xFFc58fc4);
    capPaint.style = PaintingStyle.fill;
    List<int> data = dataToPlot[0];
    int n = data.length;
    int max = 0;
    for (int i = 0; i < n; i++) {
      print(data[i]);
      if (data[i] > max) {
        max = data[i];
      }
    }
    Path path = new Path();
    Path capPath = new Path();
    double startX = margin;
    double endX = size.width - margin;
    double startY = size.height - margin;
    double endY = size.height - margin - (endX - startX) * tan(theta);
    double capX = cos(theta + pi/2) * capSize;
    double capY = -sin(theta + pi/2) * capSize;
    path.moveTo(startX, startY);
    capPath.moveTo(startX, startY);
    capPath.lineTo(startX + capX, startY + capY);
    for (int i = 0; i < n; i++) {
      double v = data[i].toDouble();
      double x = MathUtils.map(i.toDouble(), 0, (n - 1).toDouble(), startX, endX);
      double baseY = MathUtils.map(i.toDouble(), 0, (n - 1).toDouble(), startY, endY);
      double y = baseY - MathUtils.map(v, 0, max.toDouble(), 0, graphHeight);
      path.lineTo(x, y);
      capPath.lineTo(x + capX, y + capY);
    }
    for (int i = n - 1; i >= 0; i--) {
      double v = data[i].toDouble();
      double x = MathUtils.map(i.toDouble(), 0, (n - 1).toDouble(), startX, endX);
      double baseY = MathUtils.map(i.toDouble(), 0, (n - 1).toDouble(), startY, endY);
      double y = baseY - MathUtils.map(v, 0, max.toDouble(), 0, graphHeight);
      capPath.lineTo(x, y);
    }
    path.lineTo(endX, endY);
    path.lineTo(endX, endY + 1);
    path.lineTo(startX, startY + 1);
    path.close();
    canvas.drawPath(path, pathPaint);
    canvas.drawPath(capPath, capPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}