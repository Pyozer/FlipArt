import 'package:flipart/models/drawing_point.dart';

class Frame {
  List<DrawingPoint> points;

  Frame([this.points]) {
    points ??= [];
  }

  Frame copy() => Frame(points.map((pts) => pts?.copy()).toList());
}
