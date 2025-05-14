import 'package:book_mate/src/book_list/page/book_list_page.dart';
import 'package:book_mate/src/chatting/chatting_list_page.dart';
import 'package:book_mate/src/common/components/btn.dart';
import 'package:book_mate/src/follow/page/follow_list_page.dart';
import 'package:book_mate/src/home/page/home_content_page.dart';
import 'package:book_mate/src/search/page/search_page.dart';
import 'package:book_mate/src/statistics/page/statistics_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/components/app_font.dart';
import '../../common/components/icon_statistic_widget.dart';
import '../../common/components/input_widget.dart';
import '../../common/cubit/authentication_cubit.dart';
import '../../common/model/book_review_info.dart';
import '../../common/repository/review_repository.dart';
import '../../profile/cubit/user_review_cubit.dart';
import '../../recommend/page/recommend_book.dart';
import '../cubit/recently_review_cubit.dart';
import '../cubit/top_reviewer_cubit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      // 탭 변경 시 해당 탭에 수동으로 BLoC 이벤트 발행
      if (_tabController.index == 1) {
        //context.read<ChatCubit>().fetchNewMessages();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(
        controller : _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          HomeContentPage(),
          BookListPage(),
          FollowListPage(),
          StatisticsPage(),
          RecommendBook(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey,
              blurRadius: 10,
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _tabController.index,
          onTap: (index) {
            _tabController.index = index;
            setState(() {});
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xff161616),
          selectedItemColor: Color(0xe49dce62),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shelves),
              label: '서재',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '팔로우',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.stacked_bar_chart),
              label: '통계',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: '추천',
            ),
          ],
        ),
      ),
    );
  }
}



