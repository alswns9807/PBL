import 'package:bookmate/screen/library_screen.dart';
import 'package:bookmate/screen/note_screen.dart';
import 'package:bookmate/screen/statistics_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    LibraryScreen(),
    NoteScreen(),
    StatisticsScreen(),
    Placeholder(),
    Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books),
              label: '서재',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note),
              label: '노트',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '통계',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group_add),
              label: '친구',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_objects),
              label: '추천',
            ),
          ],
        ),
      ),
    );
  }
}
