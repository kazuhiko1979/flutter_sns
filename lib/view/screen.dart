//bottom Navigation
import 'package:flutter/material.dart';
import 'package:flutter_course/view/account/account_page.dart';
import 'package:flutter_course/view/time_line/post_page.dart';
import 'package:flutter_course/view/time_line/time_line_page.dart';

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  int selectedIndex = 0;
  List<Widget> pageList = [TimeLinePage(), AccountPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pageList[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.perm_identity_outlined),
              label: '',
            ),
          ],
          currentIndex: selectedIndex,
          // HomeとAccountページの切り替え
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // post時にPostPageに画面推移
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => PostPage()));
        },
        child: Icon(Icons.chat_bubble_outline),
      ),
    );
  }
}
