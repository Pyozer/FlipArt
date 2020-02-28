import 'package:flipart/models/drawing_point.dart';
import 'package:flipart/models/frame.dart';
import 'package:flipart/widgets/draw_container.dart';
import 'package:flipart/widgets/draw_painter.dart';
import 'package:flipart/widgets/flipart_title.dart';
import 'package:flipart/widgets/rounded_card.dart';
import 'package:flipart/widgets/rounded_image.dart';
import 'package:flutter/material.dart';

const kDrawRatio = 0.65;
const kFrameCardWidth = 90.0;
const kDefaultFps = 6;

class CreateAnimationScreen extends StatefulWidget {
  CreateAnimationScreen({Key key}) : super(key: key);

  @override
  _CreateAnimationScreenState createState() => _CreateAnimationScreenState();
}

class _CreateAnimationScreenState extends State<CreateAnimationScreen> {
  List<Frame> _frames;
  bool _isPlay;
  int _frameIndex;
  int _fps;

  @override
  void initState() {
    super.initState();
    _initValues();
  }

  void _initValues() {
    _frames = [Frame()];
    _isPlay = false;
    _frameIndex = 0;
    _fps = kDefaultFps;
  }

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
      _isPlay = _frames.length > 1;
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
      await Future.delayed(Duration(milliseconds: 1000 ~/ _fps));
      _frameIndex++;
      return true;
    });
  }

  void _stopRender() => setState(() => _isPlay = false);

  void _onReset() => setState(_initValues);

  Frame getFrame(int index) {
    if (_frames.length > index) return _frames[index];
    return Frame();
  }

  bool isCurrentFrame(Frame frame) => frame == getFrame(_frameIndex);

  Widget _buildSectionTitle(String title, double marginTop) {
    return Padding(
      padding: EdgeInsets.only(left: 16.0, top: marginTop),
      child: Text(title, style: Theme.of(context).textTheme.bodyText2),
    );
  }

  Widget _buildFrame(Frame frame, Size cardSize, double screenWidth) {
    return RoundedCard(
      margin: const EdgeInsets.only(right: 12.0),
      borderColor: isCurrentFrame(frame) ? Colors.blue : null,
      onLongPress: () => _duplicateFrame(frame),
      onPress: () => _selectFrame(frame),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          RoundedWidget(
            child: Transform.scale(
              scale: kFrameCardWidth / screenWidth,
              alignment: Alignment.topLeft,
              child: CustomPaint(
                size: cardSize,
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
    );
  }

  Widget _buildFrames(double screenWidth) {
    const cardSize = Size(kFrameCardWidth, kFrameCardWidth * kDrawRatio);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 12.0),
      child: Row(
        children: [
          ..._frames.map((frame) => _buildFrame(frame, cardSize, screenWidth)),
          RoundedCard(
            margin: const EdgeInsets.only(right: 12.0),
            child: SizedBox.fromSize(
              size: cardSize,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _addNewImage,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionSpeed() {
    return RoundedCard(
      margin: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
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
            const FlipArtTitle(subtitle: "Create animation"),
            _buildSectionTitle('Render at $_fps FPS', 6),
            DrawContainer(
              width: size.width,
              height: size.width * kDrawRatio,
              frame: getFrame(_frameIndex),
              previousFrame: _frames.length > 1 && _frameIndex > 0 && !_isPlay
                  ? _frames[_frameIndex - 1]
                  : null,
              onNewPoint: _onNewPoint,
              onUndo: _onUndo,
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 42.0),
                children: [
                  _buildSectionTitle('${_frames.length} Frames', 0.0),
                  _buildFrames(size.width),
                  _buildSectionTitle('Transition speed', 10),
                  _buildTransitionSpeed(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        disabledElevation: 0.0,
        onPressed: _frames.length > 1 ? (_isPlay ? _stopRender : _playRender) : null,
        tooltip: '${_isPlay ? "Pause" : "Play"} animation',
        child: _isPlay ? const Icon(Icons.pause) : const Icon(Icons.play_arrow),
      ),
    );
  }
}
