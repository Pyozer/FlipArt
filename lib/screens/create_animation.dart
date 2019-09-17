import 'dart:io';

import 'package:flipart/models/frame.dart';
import 'package:flipart/widgets/draw_container.dart';
import 'package:flipart/widgets/draw_painter.dart';
import 'package:flipart/widgets/flipart_title.dart';
import 'package:flipart/widgets/rounded_card.dart';
import 'package:flipart/widgets/rounded_image.dart';
import 'package:flipart/widgets/shadow_icon.dart';
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

  Future<void> addNewImage() async {
    setState(() {
      _frames.add(Frame());
      _frameIndex = _frames.length - 1;
    });
  }

  void removeFrame(Frame frame) {
    setState(() {
      _frames.remove(frame);
      if (_frames.isEmpty) _frames.add(Frame());
      _frameIndex = 0;
    });
  }

  void selectFrame(Frame frame) {
    setState(() => _frameIndex = _frames.indexOf(frame));
  }

  void _playRender() async {
    if (_frames.isEmpty) return;

    _isPlay = true;
    _frameIndex = 0;

    await Future.doWhile(() async {
      if (!_isPlay || !mounted) return false;

      setState(() => _frameIndex %= _frames.length);
      await Future.delayed(Duration(milliseconds: 1000 ~/ _fps)); // 12FPS
      _frameIndex++;
      return true;
    });
    if (mounted) setState(() => _frameIndex = 0);
  }

  void _stopRender() => setState(() => _isPlay = false);

  void _saveAnimation() {}

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
            SizedBox(
              width: size.width,
              height: size.width * 0.8,
              child: RoundedCard(
                elevation: 4.0,
                margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 16.0),
                child: DrawContainer(
                  frame: _frames[_frameIndex],
                  previousFrame: _frameIndex > 0 && !_isPlay
                      ? _frames[_frameIndex - 1]
                      : null,
                  onNewPoint: (p) {
                    setState(() => _frames[_frameIndex].points.add(p));
                  },
                  onClear: () {
                    setState(() => _frames[_frameIndex].points.clear());
                  },
                ),
              ),
            ),
            _buildSectionTitle('Images'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 0.0, 12.0),
              child: Row(
                children: [
                  ..._frames.map(
                    (frame) => RoundedCard(
                      margin: EdgeInsets.zero,
                      onLongPress: () => removeFrame(frame),
                      onPress: () => selectFrame(frame),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          RoundedWidget(
                            child: Transform.scale(
                              scale: 0.24,
                              alignment: Alignment.topLeft,
                              child: CustomPaint(
                                size: Size(100.0, 80.0),
                                painter: DrawingPainter(
                                  frame: frame,
                                ),
                              ),
                            ),
                          ),
                          ShadowIcon(
                            icon: Icons.delete_outline,
                            iconColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: RoundedCard(
                      child: SizedBox.fromSize(
                        size: const Size(100.0, 80.0),
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: addNewImage,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildSectionTitle('Controls'),
            RoundedCard(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    _isPlay
                        ? IconButton(
                            icon: const Icon(Icons.pause),
                            onPressed: _frames.isNotEmpty ? _stopRender : null,
                          )
                        : IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: _frames.isNotEmpty ? _playRender : null,
                          ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveAnimation,
        tooltip: 'Save animation',
        child: const Icon(Icons.save),
      ),
    );
  }
}
