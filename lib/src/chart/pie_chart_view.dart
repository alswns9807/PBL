import 'package:book_mate/src/chart/pie_chart_widget.dart';
import 'package:book_mate/src/common/components/app_font.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartView extends StatelessWidget {
  const PieChartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 4,
        child: LayoutBuilder(
          builder: (context, constraint) => Container(
            decoration: const BoxDecoration(
                color: Color.fromRGBO(193, 214, 233, 1),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    spreadRadius: -10,
                    blurRadius: 17,
                    offset: Offset(-5, -5),
                    color: Colors.white,
                  ),
                  BoxShadow(
                      spreadRadius: -2,
                      blurRadius: 10,
                      offset: Offset(7, 7),
                      color: Color.fromRGBO(
                        146,
                        182,
                        216,
                        1,
                      ))
                ]),
            child: Stack(
              children: [
                Center(
                  child: SizedBox(
                    width: constraint.maxWidth * 0.6,
                    child: CustomPaint(
                      foregroundPainter: PieChartWidget(
                        width: constraint.maxWidth * 0.5,
                        categories: kCategories
                      ),
                      child: const Center(
                        child: AppFont(
                          '장르별',
                          size: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}