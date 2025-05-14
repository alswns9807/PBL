import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'app_font.dart';

class IconStatisticWidget extends StatelessWidget {
  final String iconPath;
  final int value;
  const IconStatisticWidget(
      {required this.value, required this.iconPath, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      SvgPicture.asset(iconPath),
      const SizedBox(width: 6),
      AppFont(
        value.toString(),
        size: 13,
        color: const Color(0xff5F5F5F),
      )
    ]);
  }
}