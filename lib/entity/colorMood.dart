import 'package:flutter/material.dart';

ThemeData dark_mode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
      primary: Color.fromARGB(255, 0x60, 0xC7, 0x97),
      surface: Color.fromARGB(255, 0x28, 0x28, 0x28),
      secondary: Color.fromARGB(255, 146, 95, 1),
      // Color.fromARGB(255, 145, 132, 107)
      onPrimary: Colors.black,
      onSurface: Color.fromARGB(255, 248, 218, 64)),
);

ThemeData light_mode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
      primary: Color.fromARGB(255, 0, 59, 73),
      surface: Color.fromARGB(255, 214, 210, 196),
      secondary: Color.fromARGB(255, 146, 95, 1),
      // Color.fromARGB(255, 145, 132, 107)
      onPrimary: Color.fromARGB(255, 214, 210, 196),
      onSurface: Color.fromARGB(255, 0, 59, 73)),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromARGB(255, 0, 59, 73),
    foregroundColor: Color.fromARGB(255, 214, 210, 196),
  ),
);
