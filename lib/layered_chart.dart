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
      color: const Color(0xFFFF00FF),
    );
  }
}