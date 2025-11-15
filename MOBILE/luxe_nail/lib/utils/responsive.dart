import 'package:flutter/material.dart';

class Responsive {
  static double sW(BuildContext context, num size) {
    final w = MediaQuery.of(context).size.width;
    return size * (w / 412);
  }

  static double sH(BuildContext context, num size) {
    final h = MediaQuery.of(context).size.height;
    return size * (h / 917);
  }
}
