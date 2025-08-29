import 'package:flutter/material.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class TitleTextWidget extends StatelessWidget {
  final String text;
  final double textSize;
  const TitleTextWidget({super.key, required this.text, this.textSize = 24});

  @override
  Widget build(BuildContext context) {
    return TebText(
      text,
      textSize: textSize,
      textWeight: FontWeight.bold,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}
