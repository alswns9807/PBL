import 'package:book_mate/src/chart/categories_row.dart';
import 'package:book_mate/src/common/components/app_font.dart';
import 'package:flutter/material.dart';

import '../../chart/pie_chart_view.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatefulWidget> createState() => _StatisticsPageState();

}

class _StatisticsPageState extends State<StatisticsPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: AppFont(
          '통계',
          fontWeight: FontWeight.bold,
          size: 20,
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Color(0xe49dce62),
          indicatorColor: Color(0xe49dce62),
          tabs: const [
            Tab(text: '장르별'),
            Tab(text: '월별'),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 650,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        PieChartView(),
                        CategoriesRow(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}
