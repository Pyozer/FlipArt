import 'dart:io';

import 'package:flipart/widgets/flipart_title.dart';
import 'package:flipart/widgets/rounded_card.dart';
import 'package:flipart/widgets/rounded_image.dart';
import 'package:flipart/widgets/shadow_icon.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    final image = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 1500,
      maxWidth: 1500,
    );
    if (image != null && mounted) setState(() => _images.add(image));
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
      await Future.delayed(const Duration(milliseconds: 1000)); // 12FPS
      _currentRenderIndex++;
      return true;
    });
    if (mounted) setState(() => _currentRenderIndex = null);
  }

  void _stopRender() => setState(() => _isPlay = false);

  void _saveAnimation() {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            FlipArtTitle(subtitle: "Create animation"),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text('Images', style: Theme.of(context).textTheme.body1),
            ),
            Container(
              height: 130.0,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                children: [
                  ..._images.map((image) => Center(
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
                                  height: 100.0,
                                  width: 100.0,
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
                      )),
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
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text('Render', style: Theme.of(context).textTheme.body1),
            ),
            SizedBox.fromSize(
              size: Size(size.width, size.width * 0.8),
              child: RoundedCard(
                elevation: 5.0,
                margin: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 16.0),
                child: Container(
                  height: size.width,
                  child: _currentRenderIndex != null
                      ? Image.file(_images[_currentRenderIndex])
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 12.0),
              child: Text('Controls', style: Theme.of(context).textTheme.body1),
            ),
            RoundedCard(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
                child: Row(
                  children: [
                    Column(
                      children: [
                        _isPlay
                            ? IconButton(
                                icon: Icon(Icons.pause),
                                onPressed:
                                    _images.isNotEmpty ? _stopRender : null,
                                tooltip: "Pause render",
                              )
                            : IconButton(
                                icon: Icon(Icons.play_arrow),
                                onPressed:
                                    _images.isNotEmpty ? _playRender : null,
                                tooltip: "Play render",
                              ),
                        Text(_isPlay ? "Pause" : "Play"),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Slider(
                            value: _fps.toDouble(),
                            min: 1.0,
                            max: 60.0,
                            divisions: 60,
                            onChanged: (v) => setState(() => _fps = v.round()),
                            label: "$_fps",
                          ),
                          Text("$_fps FPS"),
                        ],
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
