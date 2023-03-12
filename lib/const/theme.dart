import 'package:cysecurity/const/colors.dart';
import 'package:flutter/material.dart';

class MyThemes {

  static final ThemeData mainTheme = ThemeData(
    primaryColor: AppColor.primary,
    appBarTheme: const AppBarTheme(color: AppColor.primary),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Colors.grey,
      cursorColor: Color(0xff171d49),
      selectionHandleColor: Color(0xff005e91),
    ),
    backgroundColor: AppColor.background,
    scaffoldBackgroundColor: AppColor.background,
    brightness: Brightness.light,
    highlightColor: Colors.white,
    floatingActionButtonTheme: const FloatingActionButtonThemeData (backgroundColor: Colors.blue,focusColor: Colors.blueAccent , splashColor: Colors.lightBlue),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.white))
    )
  );

  static ThemeData getTheme() {
    return mainTheme;
  }

}