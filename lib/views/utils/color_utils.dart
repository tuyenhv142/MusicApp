 import 'package:flutter/material.dart';

Color hexStringToColor(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor; // Corrected this line
  }
  return Color(int.parse(hexColor, radix: 16));
}
