import 'package:flutter/material.dart';

class Variables {
  static const String appName = "Darwis App";
  static const String googleLogin = "Sign in with Google";
  static const int apiHashLimit = 20;
  static const int apiHashUploadLimit = 20;
  static const int apiPhishingLimit = 20;
}

Route createRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}