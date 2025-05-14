import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class BottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  const BottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/book_tray'); //개발 예정
        break;
      case 1:
        context.go('/recommend'); //개발 예정
        break;
      case 2:
        context.go('/home');
        break;
      case 3:
        context.go('/follow'); //개발 예정
        break;
      case 4:
        context.go('/statistics'); //개발 예정
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onTap(context, index),
      destinations: [
        NavigationDestination(icon: SvgPicture.asset('assets/svg/icons/icon_journals.svg'), label: '서재',),
        NavigationDestination(icon: SvgPicture.asset('assets/svg/icons/icon_liked.svg'), label: '추천',),
        NavigationDestination(icon: SvgPicture.asset('assets/svg/icons/apple_logo.svg'), label: '홈',),
        NavigationDestination(icon: SvgPicture.asset('assets/svg/icons/icon_people.svg'), label: '팔로우',),
        NavigationDestination(icon: SvgPicture.asset('assets/svg/icons/icon_google_logo.svg'), label: '통계',),

      ],
    );
  }
}