import 'package:flutter/material.dart';

class BBText extends StatelessWidget {
  final String data;
  final TextAlign? textAlign;
  final TextStyle? style;

  const BBText({super.key, required this.data, this.textAlign, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(data, style: style);
  }
}
