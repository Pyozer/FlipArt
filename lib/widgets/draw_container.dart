import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }

class DrawContainer extends StatefulWidget {
  @override
  _DrawState createState() => _DrawState();
}

class _DrawState extends State<DrawContainer> {
  Color _selectedColor = Colors.black;
  double _opacity = 1.0;
  double _strokeWidth = 3.0;

  List<DrawingPoints> _points = List();

  Color _pickerColor = Colors.black;
  bool _showBottomList = false;

  SelectedMode _selectedMode = SelectedMode.StrokeWidth;
  List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];

  void onDraw(Offset globalPosition) {
    setState(() {
      RenderBox renderBox = context.findRenderObject();
      _points.add(DrawingPoints(
        points: renderBox.globalToLocal(globalPosition),
        paint: Paint()
          ..strokeCap = StrokeCap.round
          ..color = _selectedColor.withOpacity(_opacity)
          ..isAntiAlias = true
          ..strokeWidth = _strokeWidth,
      ));
    });
  }

  void onTabSelect(SelectedMode tabMode) {
    setState(() {
      if (_selectedMode == tabMode) _showBottomList = !_showBottomList;
      _selectedMode = tabMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRect(
          child: GestureDetector(
            onPanUpdate: (details) => onDraw(details.globalPosition),
            onPanEnd: (_) => setState(() => _points.add(null)),
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawingPainter(pointsList: _points),
            ),
          ),
        ),
        Positioned(
          left: 16,
          bottom: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25.0),
              color: Colors.greenAccent,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.album),
                      onPressed: () => onTabSelect(SelectedMode.StrokeWidth),
                    ),
                    IconButton(
                      icon: const Icon(Icons.opacity),
                      onPressed: () => onTabSelect(SelectedMode.Opacity),
                    ),
                    IconButton(
                      icon: const Icon(Icons.color_lens),
                      onPressed: () => onTabSelect(SelectedMode.Color),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _showBottomList = false;
                          _points.clear();
                        });
                      },
                    ),
                  ],
                ),
                Visibility(
                  child: (_selectedMode == SelectedMode.Color)
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: getColorList(),
                          ),
                        )
                      : Slider(
                          value: (_selectedMode == SelectedMode.StrokeWidth)
                              ? _strokeWidth
                              : _opacity,
                          max: (_selectedMode == SelectedMode.StrokeWidth)
                              ? 50.0
                              : 1.0,
                          min: 0.0,
                          label: (_selectedMode == SelectedMode.StrokeWidth)
                              ? "${_strokeWidth.round()}px"
                              : "${(_opacity * 100).round()}%",
                          divisions: 50,
                          onChanged: (val) {
                            setState(() {
                              if (_selectedMode == SelectedMode.StrokeWidth)
                                _strokeWidth = val;
                              else
                                _opacity = val;
                            });
                          },
                        ),
                  visible: _showBottomList,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> getColorList() {
    return [
      for (Color color in _colors) colorCircle(color),
      GestureDetector(
        onTap: () {
          _pickerColor = _selectedColor;
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Color picker'),
              contentPadding: const EdgeInsets.only(top: 16.0),
              content: SingleChildScrollView(
                child: ColorPicker(
                  enableAlpha: false,
                  displayThumbColor: true,
                  pickerColor: _pickerColor,
                  onColorChanged: (color) => _pickerColor = color,
                  enableLabel: false,
                ),
              ),
              actions: [
                FlatButton(
                  child: const Text("Done"),
                  onPressed: () {
                    setState(() => _selectedColor = _pickerColor);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        },
        child: Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 36.0,
            width: 36.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(
                colors: [Colors.red, Colors.green, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Material(
        elevation: 2,
        color: color,
        type: MaterialType.circle,
        child: SizedBox(height: 36, width: 36.0),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoints> pointsList;

  const DrawingPainter({this.pointsList});

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(
          pointsList[i].points,
          pointsList[i + 1].points,
          pointsList[i].paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
