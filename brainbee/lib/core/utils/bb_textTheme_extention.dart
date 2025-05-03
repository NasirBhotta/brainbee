import 'package:flutter/material.dart';

extension BBTextThemeExtension on BuildContext {
  TextTheme get textStyle => Theme.of(this).textTheme;
}
