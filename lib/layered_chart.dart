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
      child: new CustomPaint(size: new Size(800, 800), foregroundPainter: new ChartPainter(widget.dataToPlot))
    );
  }
}

class ChartPainter extends CustomPainter {

  List<List<int>> dataToPlot;

  ChartPainter(List<List<int>> dataToPlot) {
    this.dataToPlot = dataToPlot;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint pathPaint = new Paint();
    pathPaint.color = new Color.fromARGB(255, 255, 0, 0);
    pathPaint.style = PaintingStyle.fill;
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
    path.moveTo(0, size.height);
    for (int i = 0; i < n; i++) {
      double v = data[i].toDouble();
      double x = MathUtils.map(i.toDouble(), 0, (n - 1).toDouble(), 0, size.width);
      double y = MathUtils.map(v, 0, max.toDouble(), size.height, 0);
      path.lineTo(x, y);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}