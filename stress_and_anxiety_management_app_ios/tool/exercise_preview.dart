import 'package:flutter/material.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Screens/ExerciseChooseScreen.dart';
import 'package:stress_and_anxiety_management_app_ios/WithMe/Theme/WithMeTheme.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildWithMeTheme(),
    builder: (context, child) => ColoredBox(
      color: const Color(0xffe4ece6),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: child!,
        ),
      ),
    ),
    home: const ExerciseChooseScreen(),
  ),
);
