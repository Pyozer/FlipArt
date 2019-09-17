import 'package:flipart/widgets/rounded_image.dart';
import 'package:flutter/material.dart';

class AnimationGridItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          RoundedWidget(
            child: Image.network(
              "https://cdn.dribbble.com/users/175166/screenshots/5294565/flipbook2.gif",
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "My first animation",
                    style: textTheme.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12.0),
                Text("12 FPS / 10 sec", style: textTheme.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
