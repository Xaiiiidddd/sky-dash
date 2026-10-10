import 'package:flutter/material.dart';

/// ════════════════════════════════════════════════════════════════
/// 🎓 STUDENT CODE FILE — Sky Dash edition
/// Contains every getter that WorkshopSettings (game_settings.dart)
/// calls, so nothing is "Member not found".
/// ════════════════════════════════════════════════════════════════

class StudentCode {
  // TASK 1: Bird color
  static Color getBirdColor() => Colors.deepOrange;

  // TASK 2: Gravity
  static double getGravity() => 1000;

  // TASK 3: Gap size
  static double getGapSize() => 230;

  // TASK 4: Pipe speed
  static double getPipeSpeed() => 180;

  // TASK 5: Jump strength (scales with gravity)
  static double calculateJumpStrength(double gravity) => gravity * -0.4;

  // TASK 6: Pipe color
  static Color getPipeColor() => const Color(0xFF1DE9B6);

  // TASK 7: Sky colors (daytime palette; the game cycles through more)
  static Color getSkyTopColor() => const Color(0xFF3FA9F5);
  static Color getSkyBottomColor() => const Color(0xFFBDE7FF);

  // TASK 8: Points per pipe
  static int calculatePoints(int currentScore) => 1;

  // TASK 9: Your name
  static String getCreatorName() => "Zaid";
}