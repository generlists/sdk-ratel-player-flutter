
import 'package:flutter/material.dart';
//todo
typedef PlayerStyleBuilder = PlayerStyle Function(PlayerStyle defaultStyle);

class PlayerStyle {
  final bool showVideoProgressIndicator;
  final Color progressIndicatorColor;
  final Color playedColor;
  final Color handledColor;

  const PlayerStyle({
    this.showVideoProgressIndicator = true,
    this.progressIndicatorColor = Colors.amber,
    this.playedColor = Colors.amber,
    this.handledColor = Colors.amberAccent,
  });
}