import 'package:flutter/widgets.dart';

final class AppRadii {
  AppRadii._();

  static const double xs = 12;
  static const double sm = 16;
  static const double md = 20;
  static const double lg = 24;
  static const double xl = 28;
  static const double hero = 32;
  static const double pill = 999;

  static const Radius lgRadius = Radius.circular(lg);
  static const Radius xlRadius = Radius.circular(xl);
  static const BorderRadius card = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(xl));
}
