import 'dart:io';

import 'package:flipart/screens/draw_screen.dart';
import 'package:flipart/widgets/draw_container.dart';
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
  List<File> _images = <File>[];
  int _currentRenderIndex;
  bool _isPlay = false;
  int _fps = 12;

  Future<void> addNewImage() async {
    final image = await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => DrawScreen(),
      fullscreenDialog: true,
    ));
  }

  void removeImage(File image) {
    setState(() {
      _images.remove(image);
      _currentRenderIndex = _images.isNotEmpty ? 0 : null;
    });
  }

  void selectFrame(File image) {
    setState(() => _currentRenderIndex = _images.indexOf(image));
  }

  void _playRender() async {
    if (_images.isEmpty) return;

    _isPlay = true;
    _currentRenderIndex = 0;

    await Future.doWhile(() async {
      if (!_isPlay || !mounted) return false;

      setState(() => _currentRenderIndex %= _images.length);
      await Future.delayed(Duration(milliseconds: 1000 ~/ _fps)); // 12FPS
      _currentRenderIndex++;
      return true;
    });
    if (mounted) setState(() => _currentRenderIndex = null);
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
            SizedBox.fromSize(
              size: Size(size.width, size.width * 0.8),
              child: RoundedCard(
                elevation: 5.0,
                margin: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 16.0),
                child: Container(
                  height: size.width,
                  child: DrawContainer(),
                ),
              ),
            ),
            _buildSectionTitle('Images'),
            Container(
              height: 130.0,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                children: [
                  ..._images.map(
                    (image) => Center(
                      child: SizedBox.fromSize(
                        size: Size.square(50),
                        child: RoundedCard(
                          margin: const EdgeInsets.only(right: 8.0),
                          onLongPress: () => removeImage(image),
                          onPress: () => selectFrame(image),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              RoundedWidget(
                                child: Image.file(
                                  image,
                                  height: 50.0,
                                  width: 50.0,
                                  fit: BoxFit.cover,
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
                    ),
                  ),
                  Center(
                    child: RoundedCard(
                      margin: EdgeInsets.zero,
                      child: SizedBox.fromSize(
                        size: Size.square(100.0),
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: addNewImage,
                        ),
                      ),
                    ),
                  )
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
                            onPressed: _images.isNotEmpty ? _stopRender : null,
                          )
                        : IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: _images.isNotEmpty ? _playRender : null,
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
