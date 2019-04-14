import 'dart:math';

import 'package:flutter_web.examples.github_dataviz/catmull.dart';
import 'package:flutter_web.examples.github_dataviz/mathutils.dart';
import 'package:flutter_web/widgets.dart';
import 'package:flutter_web/painting.dart';

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
    return new Container(
      color: const Color(0xFF000020),
      child: new CustomPaint(foregroundPainter: new ChartPainter(widget.dataToPlot, 80, 200, 130, 10, 60, 10, 1500), child: new Container())
    );
  }
}

class ChartPainter extends CustomPainter {

  List<List<int>> dataToPlot;
  double margin;
  double graphHeight;
  double graphGap;
  double theta;
  double capTheta;
  double capSize;
  int numPoints;

  ChartPainter(List<List<int>> dataToPlot, double margin, double graphHeight, double graphGap, double degrees, double capDegrees, double capSize, int numPoints) {
    this.dataToPlot = dataToPlot;
    this.margin = margin;
    this.graphHeight = graphHeight;
    this.graphGap = graphGap;
    this.theta = pi * degrees / 180;
    this.capTheta = pi * capDegrees / 180;
    this.capSize = capSize;
    this.numPoints = numPoints;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint pathPaint = new Paint();
    pathPaint.color = new Color(0x80c58fc4);
    pathPaint.style = PaintingStyle.fill;
    Paint capPaint = new Paint();
    capPaint.color = new Color(0xFFc58fc4);
    capPaint.style = PaintingStyle.stroke;
    capPaint.strokeWidth = 1.5;
    Paint textPaint = new Paint();
    textPaint.color = new Color(0xFFFFFFFF);
    print("PAINTING");
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
    List<Color> colors = [
      new Color(0xff614661),
      new Color(0xff21464c),
      new Color(0xff3c6544),
      new Color(0xff5e613a),
    ];
    List<Color> capColors = [
      new Color(0xffc58fc4),
      new Color(0xff348c9a),
      new Color(0xff72c785),
      new Color(0xffbec271),
    ];
    int m = 4; // todo - base it on the data length
    double totalGap = m * graphGap;
    double xIndent = totalGap / tan(capTheta);
    double dx = xIndent / (m - 1);
    List<int> data = dataToPlot[1];
    int n = data.length;
    int maxValue = 0;
    List<Point2D> controlPoints = new List<Point2D>();
    controlPoints.add(new Point2D(-1, 0));
    double last = 0;
    for (int i = 0; i < n; i++) {
      if (data[i] > maxValue) {
        maxValue = data[i];
      }
      double v = data[i].toDouble();
      controlPoints.add(new Point2D(i.toDouble(), v));
      last = v;
    }
    controlPoints.add(new Point2D(n.toDouble(), last));
    CatmullInterpolator curve = new CatmullInterpolator(controlPoints);
    double startX = margin + xIndent;
    double endX = size.width - margin;
    double startY = size.height - margin;
    double endY = size.height - margin - (endX - startX) * tan(theta);
    double capX = cos(capTheta + pi/2) * capSize;
    double capY = -sin(capTheta + pi/2) * capSize;
//    TextStyle textStyle = new TextStyle();
//    ParagraphBuilder paragraphBuilder = new ParagraphBuilder(new ParagraphStyle(fontSize: 10));

    // paragraphBuilder.pushStyle(new TextStyle);
//    paragraphBuilder.addText("LINES COMMITTED");
//    Paragraph paragraph = paragraphBuilder.build();
    for (int j = m-1; j >=0; j--) {
      canvas.save();
      canvas.translate(-dx * j, -graphGap * j);
//      canvas.drawParagraph(paragraph, new Offset(startX, startY + 5));

      TextSpan span = new TextSpan(style: new TextStyle(color: Color.fromARGB(255, 255, 255, 255)), text: "Testing");
      TextPainter tp = new TextPainter(text: span, textAlign: TextAlign.left, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, new Offset(startX, startY + 5));

      pathPaint.color = colors[j];
      capPaint.color = capColors[j];
      Path path = new Path();
      Path capPath = new Path();
      path.moveTo(startX, startY);
      capPath.moveTo(startX + capX, startY + capY);
      ControlPointAndValue cpv = new ControlPointAndValue();
      for (int i = 0; i < numPoints; i++) {
        double input = MathUtils.map(i.toDouble(), 0, numPoints.toDouble(), 0, n.toDouble());
        cpv.value = input;
        curve.progressiveGet(cpv);
        double v = max(0, cpv.value);
        double x = MathUtils.map(i.toDouble(), 0, (numPoints - 1).toDouble(), startX, endX);
        double baseY = MathUtils.map(i.toDouble(), 0, (numPoints - 1).toDouble(), startY, endY);
        double y = baseY - MathUtils.map(v, 0, maxValue.toDouble(), 0, graphHeight);
        path.lineTo(x, y);
        capPath.lineTo(x + capX, y + capY);
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
      for (int i = 0; i < capSize; i++) {
        canvas.save();
        canvas.translate(-i * capX / capSize, -i * capY / capSize);
        canvas.drawPath(capPath, capPaint);
        canvas.restore();
      }
      canvas.drawPath(path, pathPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}