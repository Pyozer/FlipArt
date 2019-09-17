import 'package:flutter/material.dart';

class RoundedWidget extends StatelessWidget {
  final Widget child;

  const RoundedWidget({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: child,
    );
  }
}
