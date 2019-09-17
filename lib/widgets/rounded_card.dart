import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  final double elevation;
  final Widget child;
  final EdgeInsets margin;
  final VoidCallback onPress;
  final VoidCallback onLongPress;

  const RoundedCard({
    Key key,
    this.elevation = 3.0,
    this.margin = const EdgeInsets.all(16.0),
    @required this.child,
    this.onPress,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation,
      margin: margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: child,
    );

    return (onPress ?? onLongPress) != null
        ? GestureDetector(
            onTap: onPress,
            onLongPress: onLongPress,
            behavior: HitTestBehavior.translucent,
            child: card,
          )
        : card;
  }
}
