import 'dart:math';

abstract class Interpolator {

  double get(double x);

}

class Point2D {

  double x, y;

  Point2D(this.x, this.y);

}

class MathUtils {

  static double map(double x, double a, double b, double u, double v) {
    double p = (x-a) / (b - a);
    return u + p * (v - u);
  }

  static double clampedMap(double x, double a, double b, double u, double v) {
    if (x <= a) {
      return u;
    } else if (x >= b) {
      return v;
    } else {
      double p = (x - a) / (b - a);
      return u + p * (v - u);
    }
  }

}