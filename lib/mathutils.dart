import 'dart:math';

abstract class Interpolator {

  double get(double x);

}

class EarlyInterpolator implements Interpolator {

  double amount;

  EarlyInterpolator(this.amount);

  @override
  double get(double x) {
    if (x >= amount) {
      return 1;
    } else {
      return MathUtils.map(x, 0, amount, 0, 1);
    }
  }
}

class Point2D {

  double x, y;

  Point2D(this.x, this.y);

}

class MathUtils {

  static double map(double x, double a, double b, double u, double v, {Interpolator interpolator}) {
    double p = (x-a) / (b - a);
    double y = u + p * (v - u);
    return interpolator == null ? y : interpolator.get(y);
  }

  static double clampedMap(double x, double a, double b, double u, double v, {Interpolator interpolator}) {
    double y;
    if (x <= a) {
      y = u;
    } else if (x >= b) {
      y = v;
    } else {
      double p = (x - a) / (b - a);
      y = u + p * (v - u);
    }
    return interpolator == null ? y : interpolator.get(y);
  }

  static double clamp(double x, double a, double b) {
    if (x < a) return a;
    if (x > b) return b;
    return x;
  }

}