import 'package:flutter/material.dart';

class WidgetUtils {
  static AppBar createAppBar(String title) {
    return AppBar(
      backgroundColor: const Color.fromARGB(0, 252, 248, 248),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Text(
        title,
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: true,
    );
  }
}
