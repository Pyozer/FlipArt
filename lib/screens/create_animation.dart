import 'package:flipart/models/drawing_point.dart';
import 'package:flipart/models/frame.dart';
import 'package:flipart/widgets/draw_container.dart';
import 'package:flipart/widgets/draw_painter.dart';
import 'package:flipart/widgets/flipart_title.dart';
import 'package:flipart/widgets/rounded_card.dart';
import 'package:flipart/widgets/rounded_image.dart';
import 'package:flutter/material.dart';

class CreateAnimationScreen extends StatefulWidget {
  CreateAnimationScreen({Key key}) : super(key: key);

  @override
  _CreateAnimationScreenState createState() => _CreateAnimationScreenState();
}

class _CreateAnimationScreenState extends State<CreateAnimationScreen> {
  List<Frame> _frames = <Frame>[Frame()];

  int _frameIndex = 0;
  bool _isPlay = false;
  int _fps = 12;

  void _addNewImage() async {
    setState(() {
      _frames.add(Frame());
      _frameIndex = _frames.length - 1;
    });
  }

  void _removeFrame(Frame frame) {
    setState(() {
      _frames.remove(frame);
      if (_frames.isEmpty) _frames.add(Frame());
      _frameIndex = 0;
    });
  }

  void _duplicateFrame(Frame frame) {
    final index = _frames.indexOf(frame);
    setState(() {
      _frames.insert(index + 1, frame.copy());
      _frameIndex = index + 1;
    });
  }

  void _onUndo() {
    if (_frames[_frameIndex].points.last == null)
      _frames[_frameIndex].points.removeLast();

    int lastIndexNull = _frames[_frameIndex].points.lastIndexOf(null);
    if (lastIndexNull == -1) lastIndexNull = 0;
    setState(() {
      _frames[_frameIndex].points = _frames[_frameIndex]
          .points
          .getRange(0, lastIndexNull)
          .toList()
            ..add(null);
    });
  }

  void _onNewPoint(DrawingPoint point) {
    setState(() => _frames[_frameIndex].points.add(point));
  }

  void _selectFrame(Frame frame) {
    setState(() => _frameIndex = _frames.indexOf(frame));
  }

  void _playRender() async {
    if (_frames.isEmpty) return;

    _isPlay = true;

    await Future.doWhile(() async {
      if (!_isPlay || !mounted) return false;

      setState(() => _frameIndex %= _frames.length);
      await Future.delayed(Duration(milliseconds: 1000 ~/ _fps)); // 12FPS
      _frameIndex++;
      return true;
    });
  }

  void _stopRender() => setState(() => _isPlay = false);

  void _onReset() {
    setState(() {
      _frames = [Frame()];
      _frameIndex = 0;
    });
  }

  void _saveAnimation() {
    // TODO: Save animation to GIF
  }

  bool isCurrentFrame(Frame frame) => frame == _frames[_frameIndex];

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 12.0),
      child: Text(title, style: Theme.of(context).textTheme.body1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlipArtTitle(subtitle: "Create animation"),
            _buildSectionTitle('Render at $_fps FPS'),
            DrawContainer(
              width: size.width,
              height: size.width * 0.8,
              frame: _frames[_frameIndex],
              previousFrame: (_frameIndex > 0 && !_isPlay)
                  ? _frames[_frameIndex - 1]
                  : null,
              onNewPoint: _onNewPoint,
              onUndo: _onUndo,
            ),
            _buildSectionTitle('${_frames.length} Frames'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 0.0, 12.0),
              child: Row(
                children: [
                  ..._frames.map(
                    (frame) => RoundedCard(
                      margin: const EdgeInsets.only(right: 12.0),
                      borderColor: isCurrentFrame(frame) ? Colors.blue : null,
                      onLongPress: () => _duplicateFrame(frame),
                      onPress: () => _selectFrame(frame),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          RoundedWidget(
                            child: Transform.scale(
                              scale: 0.24,
                              alignment: Alignment.topLeft,
                              child: CustomPaint(
                                size: const Size(100.0, 80.0),
                                painter: DrawingPainter(frame: frame),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => _removeFrame(frame),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RoundedCard(
                    margin: const EdgeInsets.only(right: 12.0),
                    child: SizedBox.fromSize(
                      size: const Size(100.0, 80.0),
                      child: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _addNewImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSectionTitle('Transition speed'),
            RoundedCard(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _fps.toDouble(),
                        min: 1.0,
                        max: 60.0,
                        divisions: 60,
                        onChanged: (v) => setState(() => _fps = v.round()),
                        label: "$_fps FPS",
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: _onReset,
                      tooltip: "Reset animation",
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _frames.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _isPlay ? _stopRender : _playRender,
              tooltip: '${_isPlay ? "Pause" : "Play"} animation',
              child: _isPlay
                  ? const Icon(Icons.pause)
                  : const Icon(Icons.play_arrow),
            ),
    );
  }
}
