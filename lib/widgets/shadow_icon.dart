import 'package:flutter/material.dart';

class ShadowIcon extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final double size;

  const ShadowIcon({
    Key key,
    @required this.icon,
    this.iconColor = Colors.white,
    this.size = 24.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(icon, color: Colors.black87, size: size + 2),
        Icon(icon, color: iconColor, size: size),
      ],
    );
  }
}
