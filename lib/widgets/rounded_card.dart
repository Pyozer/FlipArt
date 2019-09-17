import 'package:flutter/material.dart';

class RoundedCard extends StatelessWidget {
  final double elevation;
  final Color borderColor;
  final Widget child;
  final EdgeInsets margin;
  final Color backgroundColor;
  final double borderRadius;
  final VoidCallback onPress;
  final VoidCallback onLongPress;

  const RoundedCard({
    Key key,
    this.elevation = 3.0,
    this.borderColor,
    this.borderRadius = 8.0,
    this.margin = const EdgeInsets.all(16.0),
    this.backgroundColor,
    @required this.child,
    this.onPress,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation,
      margin: margin,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: borderColor != null
            ? BorderSide(color: borderColor)
            : BorderSide.none,
      ),
      child: child,
    );

    return (onPress ?? onLongPress) != null
        ? GestureDetector(
            onTap: onPress,
            onLongPress: onLongPress,
            child: card,
          )
        : card;
  }
}
