
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFont extends StatelessWidget {
  final String text;
  final double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final double? lineHeight;
  final int? maxLine;
  final TextOverflow? overflow;

  const AppFont(
      this.text, {
        super.key,
        this.textAlign = TextAlign.left,
        this.color = Colors.white,
        this.fontWeight = FontWeight.normal,
        this.size = 15,
        this.maxLine,
        this.lineHeight,
        this.overflow,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLine,
      overflow: overflow,
      style: GoogleFonts.notoSans(
        fontSize: size,
        fontWeight: fontWeight,
        color: color,
        height: lineHeight,
      ),
    );
  }
}

