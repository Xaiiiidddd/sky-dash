import 'package:flutter/material.dart';
import 'package:flappy_flame/workshop/student_code.dart';

/// ════════════════════════════════════════════════════════════════
/// 🎮 GAME SETTINGS — SKY DASH EDITION
/// ════════════════════════════════════════════════════════════════
/// Fallback values below match the Sky Dash game (main.dart):
/// gravity 1100, gap 230, speed 180, jump = gravity * -0.4,
/// neon-teal pipes, emoji art, day/night cycle, coins and particles.

class WorkshopSettings {
  // ═══════════════════════════════════════════════════════════════
  // 🎯 CHOOSE MODE
  // ═══════════════════════════════════════════════════════════════

  /// Set to TRUE: Use code from student_code.dart
  /// Set to FALSE: Use settings from this file
  static const bool useStudentCode = true;

  // ═══════════════════════════════════════════════════════════════
  // 🐦 BIRD SETTINGS (emoji bird that evolves with your score)
  // ═══════════════════════════════════════════════════════════════

  static const Color _birdColorFallback = Color(0xFFFF5722); // deep orange
  static Color get birdColor =>
      useStudentCode ? StudentCode.getBirdColor() : _birdColorFallback;

  static const double birdSize = 44;
  static const double birdHitRadius = 17;
  static const double birdStartX = 100;
  static const double birdStartXFraction = 0.28; // of screen width
  static const Color birdEyeColor = Colors.white;
  static const Color birdPupilColor = Colors.black;
  static const Color birdBeakColor = Color(0xFFFF8C00);
  static Color get birdWingColor => birdColor.withValues(alpha: 0.8);
  static const Color birdBellyColor = Color(0xFFFFF8DC);

  /// Bird evolves every [pointsPerEvolution] points
  static const String birdEmoji = '🐤';
  static const List<String> birdEvolutionEmojis = ['🐤', '🐦', '🦉', '🦅', '🐲'];
  static const int pointsPerEvolution = 10;
  static const String birdCrashEmoji = '😵';
  static const bool flipBirdToFaceRight = true;
  static const Color birdGlowColor = Colors.white;

  // ═══════════════════════════════════════════════════════════════
  // ⚙️ PHYSICS SETTINGS
  // ═══════════════════════════════════════════════════════════════

  static const double _gravityFallback = 1100;
  static double get gravity =>
      useStudentCode ? StudentCode.getGravity() : _gravityFallback;

  static const double jumpStrengthFactor = -0.4; // jump = gravity * factor
  static const double _jumpStrengthFallback = 1100 * jumpStrengthFactor; // -440
  static double get jumpStrength => useStudentCode
      ? StudentCode.calculateJumpStrength(gravity)
      : _jumpStrengthFallback;

  /// Max time step per frame (keeps physics stable on lag spikes)
  static const double maxFrameDelta = 0.033;

  // ═══════════════════════════════════════════════════════════════
  // 🚧 PIPE SETTINGS (neon glowing pipes with caps + coins)
  // ═══════════════════════════════════════════════════════════════

  static const double pipeWidth = 72;
  static const double pipeCapHeight = 28;
  static const double pipeCapOverhang = 7;

  static const double _gapHeightFallback = 230;
  static double get gapHeight =>
      useStudentCode ? StudentCode.getGapSize() : _gapHeightFallback;

  static const double _pipeSpeedFallback = 180;
  static double get pipeSpeed =>
      useStudentCode ? StudentCode.getPipeSpeed() : _pipeSpeedFallback;

  /// Difficulty ramp: harder as you score
  static const double speedIncreasePerPoint = 2.0;
  static const double maxExtraSpeed = 80;
  static const double gapShrinkPerPoint = 1.2;

  /// New pipe spawns when the last one is this far from the right edge
  static const double pipeSpawnDistance = 250;
  static const double pipeSpawnInterval = 1.4; // ≈ spawnDistance / speed
  static const double minGapDistance = 160; // smallest gap ever
  static const double pipeEdgeMargin = 90; // gap keeps this far from top/ground

  static const Color _pipeColorFallback = Color(0xFF1DE9B6); // neon teal
  static Color get pipeColor =>
      useStudentCode ? StudentCode.getPipeColor() : _pipeColorFallback;

  static Color get pipeBorderColor => Colors.white.withValues(alpha: 0.35);
  static Color get pipeHighlightColor =>
      Color.lerp(pipeColor, Colors.white, 0.3) ?? pipeColor;
  static Color get pipeShadowColor =>
      Color.lerp(pipeColor, Colors.black, 0.3) ?? pipeColor;
  static Color get pipeGlowColor => pipeColor.withValues(alpha: 0.5);
  static const double pipeGlowBlur = 16;

  // ═══════════════════════════════════════════════════════════════
  // 🌤️ SKY / BACKGROUND (day → sunset → night → dawn cycle)
  // ═══════════════════════════════════════════════════════════════

  // Static fallback = daytime palette
  static const Color _skyColorTopFallback = Color(0xFF3FA9F5);
  static const Color _skyColorBottomFallback = Color(0xFFBDE7FF);

  static Color get skyColorTop =>
      useStudentCode ? StudentCode.getSkyTopColor() : _skyColorTopFallback;
  static Color get skyColorBottom => useStudentCode
      ? StudentCode.getSkyBottomColor()
      : _skyColorBottomFallback;

  /// Day-night cycle: palette changes every [pointsPerSkyPhase] points
  static const bool enableDayNightCycle = true;
  static const int pointsPerSkyPhase = 10;
  static const double skyBlendSpeed = 1.2;

  /// top color, bottom color, star visibility (0-1), sun/moon emoji
  static const List<SkyPhase> skyPhases = [
    SkyPhase(Color(0xFF3FA9F5), Color(0xFFBDE7FF), 0.0, '☀️'), // day
    SkyPhase(Color(0xFFFF6B6B), Color(0xFFFFC371), 0.15, '🌅'), // sunset
    SkyPhase(Color(0xFF070B24), Color(0xFF3B2A78), 1.0, '🌙'), // night
    SkyPhase(Color(0xFF5B6CF0), Color(0xFFFF8FB1), 0.4, '🌄'), // dawn
  ];

  // Stars, clouds, sun/moon
  static const int starCount = 45;
  static const String starSymbol = '✦';
  static const int cloudCount = 6;
  static const String cloudEmoji = '☁️';
  static const Color cloudColor = Colors.white;
  static const double cloudOpacity = 0.75; // fades at night
  static const double sunMoonSize = 64;

  // ═══════════════════════════════════════════════════════════════
  // 🌍 GROUND (scrolling emoji grass)
  // ═══════════════════════════════════════════════════════════════

  static const double groundHeight = 80;
  static const Color groundColor = Color(0xFF5D4037);
  static const Color grassColor = Color(0xFF3E8E41);
  static const Color groundLineColor = Color(0xFFFFFFFF); // top highlight line
  static const String groundEmoji = '🌿';
  static const double groundTileWidth = 36;

  // ═══════════════════════════════════════════════════════════════
  // 🏆 SCORING, COINS & MEDALS
  // ═══════════════════════════════════════════════════════════════

  static int getPoints(int currentScore) =>
      useStudentCode ? StudentCode.calculatePoints(currentScore) : 1;

  static String get creatorName =>
      useStudentCode ? StudentCode.getCreatorName() : "Workshop Participant";

  static const String coinEmoji = '🪙';
  static const int coinPoints = 2;
  static const double coinCollectRadius = 34;
  static const bool coinSpins = true;

  static const String bestScoreEmoji = '👑';
  static const List<MedalTier> medals = [
    MedalTier(50, '🏆'),
    MedalTier(30, '🥇'),
    MedalTier(15, '🥈'),
    MedalTier(5, '🥉'),
  ];
  static const String defaultMedal = '🎯';

  // ═══════════════════════════════════════════════════════════════
  // ✨ VISUAL EFFECTS
  // ═══════════════════════════════════════════════════════════════

  static const bool enableBirdRotation = true;
  static const double maxRotationUp = -0.5;
  static const double maxRotationDown = 1.0;
  static const double crashRotation = 1.4;

  static const bool enableBirdTrail = true; // ✨ sparkles when flapping
  static const String trailEmoji = '✨';
  static const Color trailColor = Color(0xFFFFD700);
  static const double trailOpacity = 0.3;

  static const List<String> crashParticleEmojis = ['💥', '⭐', '✨', '💫'];
  static const List<String> coinParticleEmojis = ['🪙', '✨', '⭐'];
  static const int crashParticleCount = 18;
  static const int coinParticleCount = 8;

  static const bool enableScreenShake = true;
  static const double shakeIntensity = 18;
  static const double shakeDecayPerSecond = 2.5;

  /// Ignore taps this long after crashing (prevents accidental restart)
  static const double gameOverTapDelay = 0.6;

  // ═══════════════════════════════════════════════════════════════
  // 🖥️ UI / TEXT
  // ═══════════════════════════════════════════════════════════════

  static const String gameTitle = 'SKY DASH';
  static const String titleEmoji = '🦉';
  static const String tapToStartText = 'TAP TO FLAP 👆';
  static const String gameOverText = 'GAME OVER 💥';
  static const String retryText = 'TAP TO RETRY 🔁';
  static const Color glassColor = Colors.black; // frosted panels
  static const double glassOpacity = 0.28;
  static const Color newBestColor = Color(0xFFFFD54F);

  // ═══════════════════════════════════════════════════════════════
  // 🔊 SOUND
  // ═══════════════════════════════════════════════════════════════

  static const bool soundEnabled = true;

  /// Sky Dash uses Flutter's built-in SystemSound + haptics (no assets).
  /// Set to FALSE to use the .wav files below instead (Flame audio).
  static const bool useSystemSounds = true;
  static const bool enableHaptics = true;

  static const String jumpSound = 'jump.wav';
  static const String scoreSound = 'score.wav';
  static const String hitSound = 'hit.wav';
  static const String swooshSound = 'swoosh.wav';
  static const double jumpVolume = 0.5;
  static const double scoreVolume = 0.7;
  static const double hitVolume = 0.8;
  static const double swooshVolume = 0.4;
  static const double masterVolume = 1.0;

  // ═══════════════════════════════════════════════════════════════
  // 🖼️ CUSTOM IMAGES
  // ═══════════════════════════════════════════════════════════════

  static const bool useCustomBirdImage = false;
  static const bool useCustomPipeImage = false;
  static const String birdImageFile = 'bird.png';
  static const String pipeImageFile = 'pipe.png';
  static const String birdDesign = 'emoji';
  static const String pipeDesign = 'neon';
  static const Color pipeGradientStart = Color(0xFF1DE9B6);
  static const Color pipeGradientEnd = Color(0xFF00BFA5);
  static const Color candyStripe1 = Color(0xFFFF69B4);
  static const Color candyStripe2 = Colors.white;
}

/// One stage of the day-night cycle.
class SkyPhase {
  final Color top;
  final Color bottom;
  final double stars;
  final String bodyEmoji;
  const SkyPhase(this.top, this.bottom, this.stars, this.bodyEmoji);
}

/// Minimum score needed to earn a medal.
class MedalTier {
  final int minScore;
  final String emoji;
  const MedalTier(this.minScore, this.emoji);
}