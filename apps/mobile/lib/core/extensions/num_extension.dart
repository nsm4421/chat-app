import 'package:flutter/material.dart';

extension NumExtension on num {
  double get dx => toDouble();
  double get r => dx;

  SizedBox get h => SizedBox(width: dx);
  SizedBox get v => SizedBox(height: dx);

  EdgeInsets get p => EdgeInsets.all(dx);
  EdgeInsets get px => EdgeInsets.symmetric(horizontal: dx);
  EdgeInsets get py => EdgeInsets.symmetric(vertical: dx);

  BorderRadius get br => BorderRadius.circular(dx);
  Radius get radius => Radius.circular(dx);
}
