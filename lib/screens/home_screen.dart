import 'package:flipart/screens/create_animation.dart';
import 'package:flipart/widgets/animation_grid_item.dart';
import 'package:flipart/widgets/flipart_title.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _newAnimation() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => CreateAnimationScreen()
    ));
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      body: ListView.builder(
        padding: safePadding.add(const EdgeInsets.only(bottom: 80.0)),
        itemCount: 10,
        itemBuilder: (context, index) {
          if (index == 0) return FlipArtTitle();
          return AnimationGridItem();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _newAnimation,
        tooltip: 'Create new animation',
        child: const Icon(Icons.add),
      ),
    );
  }
}
