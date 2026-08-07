import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;

  static const BorderRadius roundedSmall = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMedium = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLarge = BorderRadius.all(Radius.circular(lg));
}
