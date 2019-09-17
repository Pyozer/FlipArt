import 'package:flutter/material.dart';

class FlipArtTitle extends StatelessWidget {
  final String subtitle;

  const FlipArtTitle({Key key, this.subtitle}) : super(key: key);

  Text _buildTitle() {
    return const Text(
      "FlipArt",
      style: TextStyle(fontSize: 38.0, fontWeight: FontWeight.w800),
    );
  }

  Text _buildSubTitle() {
    return Text(
      subtitle,
      style: const TextStyle(fontSize: 25.0, fontWeight: FontWeight.w300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: subtitle?.isEmpty ?? true
          ? _buildTitle()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildTitle(), _buildSubTitle()],
            ),
    );
  }
}
