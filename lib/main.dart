import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// ════════════════════════════════════════════════════════════════
/// 🦉 SKY DASH — a polished endless flyer (single file, no packages)
///
/// • Bird evolves as you score: 🐤 → 🐦 → 🦉 → 🦅 → 🐲
/// • Day → sunset → night → dawn cycle that follows your score
/// • Twinkling stars, drifting clouds, sun/moon, glowing pipes
/// • Spinning 🪙 coins, particles, screen shake, medals 🥉🥈🥇🏆
/// • Sound + haptics via Flutter's built-in SystemSound/HapticFeedback
///
/// Controls: tap / click / press SPACE.
/// Replace lib/main.dart with this file and run `flutter run`.
/// ════════════════════════════════════════════════════════════════

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: GameScreen(),
  ));
}

// ═══════════════════════════════════════════════════════════════
// 🎓 Your workshop settings (tweak these!)
// ═══════════════════════════════════════════════════════════════
class StudentCode {
  static double getGravity() => 1100;
  static double getGapSize() => 230;
  static double getPipeSpeed() => 180;
  static double calculateJumpStrength(double gravity) => gravity * -0.4;
  static Color getPipeColor() => const Color(0xFF1DE9B6);
  static int calculatePoints(int currentScore) => 1;
  static String getCreatorName() => "Zaid";
}

// ═══════════════════════════════════════════════════════════════
// 🔊 Sound + haptics
// ═══════════════════════════════════════════════════════════════
class Sfx {
  static void flap() {
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  static void score() {
    HapticFeedback.lightImpact();
    SystemSound.play(SystemSoundType.click);
  }

  static void coin() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  static void die() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
  }
}

// ═══════════════════════════════════════════════════════════════
// Models
// ═══════════════════════════════════════════════════════════════
enum GameState { ready, playing, over }

class Pipe {
  double x;
  final double gapY;
  final double gap;
  bool passed = false;
  bool coinTaken = false;
  Pipe(this.x, this.gapY, this.gap);
}

class Particle {
  double x, y, vx, vy, life;
  final String emoji;
  final double size;
  Particle(this.x, this.y, this.vx, this.vy, this.emoji, this.size)
      : life = 1.0;
}

class Cloud {
  double x, y, speed, size;
  Cloud(this.x, this.y, this.speed, this.size);
}

class SkyPalette {
  final Color top, bottom;
  final double stars;
  final String body;
  const SkyPalette(this.top, this.bottom, this.stars, this.body);
}

const _palettes = [
  SkyPalette(Color(0xFF3FA9F5), Color(0xFFBDE7FF), 0.0, '☀️'),
  SkyPalette(Color(0xFFFF6B6B), Color(0xFFFFC371), 0.15, '🌅'),
  SkyPalette(Color(0xFF070B24), Color(0xFF3B2A78), 1.0, '🌙'),
  SkyPalette(Color(0xFF5B6CF0), Color(0xFFFF8FB1), 0.4, '🌄'),
];

// ═══════════════════════════════════════════════════════════════
// Game screen
// ═══════════════════════════════════════════════════════════════
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  static const double _pipeW = 72;
  static const double _groundH = 80;
  static const double _birdR = 17;
  // Emoji direction differs per platform/font. If your bird faces left, set to true.
  static const bool _flipBird = false;

  late final Ticker _ticker;
  final _rng = Random();
  Duration _last = Duration.zero;
  double _time = 0;

  Size _size = Size.zero;
  bool _inited = false;

  GameState _state = GameState.ready;
  double _birdY = 0, _vel = 0, _overAt = 0;
  final List<Pipe> _pipes = [];
  final List<Particle> _parts = [];
  final List<Cloud> _clouds = [];
  late List<Offset> _starPos;
  late List<double> _starPhase;

  int _score = 0, _best = 0, _coins = 0;
  bool _newBest = false;
  double _shake = 0, _groundScroll = 0;

  Color _top = _palettes[0].top, _bot = _palettes[0].bottom;
  double _stars = 0;

  double get _groundTop => _size.height - _groundH;
  double get _birdX => _size.width * 0.28;
  double get _speed => StudentCode.getPipeSpeed() + min(80.0, _score * 2.0);
  int get _paletteIdx => (_score ~/ 10) % _palettes.length;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _setup(Size s) {
    _size = s;
    if (_inited) return;
    _inited = true;
    _birdY = _groundTop / 2;
    _starPos = List.generate(45,
        (_) => Offset(_rng.nextDouble() * s.width, _rng.nextDouble() * s.height * 0.6));
    _starPhase = List.generate(45, (_) => _rng.nextDouble() * 6.28);
    for (int i = 0; i < 6; i++) {
      _clouds.add(Cloud(_rng.nextDouble() * s.width, 50 + _rng.nextDouble() * s.height * 0.4,
          8 + _rng.nextDouble() * 20, 44 + _rng.nextDouble() * 40));
    }
  }

  // ───────────────────────── game loop ─────────────────────────
  void _onTick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.033);
    _last = elapsed;
    _time += dt;
    if (!_inited) return;

    final target = _palettes[_paletteIdx];
    final k = min(1.0, dt * 1.2);
    _top = Color.lerp(_top, target.top, k)!;
    _bot = Color.lerp(_bot, target.bottom, k)!;
    _stars += (target.stars - _stars) * k;

    for (final c in _clouds) {
      c.x -= c.speed * dt;
      if (c.x < -120) {
        c.x = _size.width + 60;
        c.y = 50 + _rng.nextDouble() * _size.height * 0.4;
      }
    }

    for (final p in _parts) {
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      p.vy += 300 * dt;
      p.life -= dt * 1.6;
    }
    _parts.removeWhere((p) => p.life <= 0);

    _shake = max(0, _shake - dt * 2.5);

    if (_state == GameState.ready) {
      _birdY = _groundTop / 2 + sin(_time * 3) * 10;
    } else if (_state == GameState.playing) {
      _updatePlaying(dt);
    }
    if (_state != GameState.over) _groundScroll += _speed * dt;

    setState(() {});
  }

  void _updatePlaying(double dt) {
    _vel += StudentCode.getGravity() * dt;
    _birdY += _vel * dt;

    for (final p in _pipes) {
      p.x -= _speed * dt;
    }
    _pipes.removeWhere((p) => p.x < -120);

    if (_pipes.isEmpty || _pipes.last.x < _size.width - 250) {
      final gap = max(160.0, StudentCode.getGapSize() - _score * 1.2);
      final minY = 90 + gap / 2;
      final maxY = _groundTop - 90 - gap / 2;
      _pipes.add(Pipe(_size.width + 60, minY + _rng.nextDouble() * (maxY - minY), gap));
    }

    for (final p in _pipes) {
      if (!p.passed && p.x + _pipeW < _birdX) {
        p.passed = true;
        _score += StudentCode.calculatePoints(_score);
        Sfx.score();
      }
      if (!p.coinTaken) {
        final dx = (p.x + _pipeW / 2) - _birdX;
        final dy = p.gapY - _birdY;
        if (sqrt(dx * dx + dy * dy) < 34) {
          p.coinTaken = true;
          _coins++;
          _score += 2;
          Sfx.coin();
          _burst(p.x + _pipeW / 2, p.gapY, ['🪙', '✨', '⭐'], 8, 160);
        }
      }
    }

    if (_hits()) _die();
  }

  bool _hits() {
    if (_birdY - _birdR < 0 || _birdY + _birdR > _groundTop) return true;
    for (final p in _pipes) {
      if (_birdX + _birdR > p.x && _birdX - _birdR < p.x + _pipeW) {
        if (_birdY - _birdR < p.gapY - p.gap / 2 ||
            _birdY + _birdR > p.gapY + p.gap / 2) {
          return true;
        }
      }
    }
    return false;
  }

  void _die() {
    _state = GameState.over;
    _overAt = _time;
    _shake = 1;
    if (_score > _best) {
      _best = _score;
      _newBest = _score > 0;
    }
    Sfx.die();
    _burst(_birdX, _birdY, ['💥', '⭐', '✨', '💫'], 18, 300);
  }

  void _burst(double x, double y, List<String> emojis, int n, double power) {
    for (int i = 0; i < n; i++) {
      final a = _rng.nextDouble() * 2 * pi;
      final s = power * (0.3 + _rng.nextDouble() * 0.7);
      _parts.add(Particle(x, y, cos(a) * s, sin(a) * s,
          emojis[_rng.nextInt(emojis.length)], 14 + _rng.nextDouble() * 14));
    }
  }

  void _flap() {
    _vel = StudentCode.calculateJumpStrength(StudentCode.getGravity());
    Sfx.flap();
    for (int i = 0; i < 3; i++) {
      _parts.add(Particle(_birdX - 14, _birdY + 6, -60 - _rng.nextDouble() * 60,
          20 + _rng.nextDouble() * 40, '✨', 12 + _rng.nextDouble() * 8));
    }
  }

  void _tap() {
    switch (_state) {
      case GameState.ready:
        _state = GameState.playing;
        _flap();
        break;
      case GameState.playing:
        _flap();
        break;
      case GameState.over:
        if (_time - _overAt > 0.6) _reset();
        break;
    }
  }

  void _reset() {
    _state = GameState.ready;
    _pipes.clear();
    _parts.clear();
    _score = 0;
    _coins = 0;
    _vel = 0;
    _newBest = false;
  }

  // ───────────────────────── UI helpers ─────────────────────────
  Color _a(Color c, double o) => c.withAlpha((o.clamp(0.0, 1.0) * 255).round());

  Color _shade(Color c, double amt) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + amt).clamp(0.0, 1.0)).toColor();
  }

  String get _birdEmoji => ['🐤', '🐦', '🦉', '🦅', '🐲'][min(4, _score ~/ 10)];

  String get _medal {
    if (_score >= 50) return '🏆';
    if (_score >= 30) return '🥇';
    if (_score >= 15) return '🥈';
    if (_score >= 5) return '🥉';
    return '🎯';
  }

  List<Widget> _pipeWidgets() {
    final base = StudentCode.getPipeColor();
    final w = <Widget>[];
    BoxDecoration body() => BoxDecoration(
          gradient: LinearGradient(colors: [_shade(base, -0.18), _shade(base, 0.1), _shade(base, -0.12)]),
          boxShadow: [BoxShadow(color: _a(base, 0.45), blurRadius: 16)],
        );
    BoxDecoration cap() => BoxDecoration(
          gradient: LinearGradient(colors: [_shade(base, -0.1), _shade(base, 0.18), _shade(base, -0.05)]),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _a(Colors.white, 0.35), width: 2),
          boxShadow: [BoxShadow(color: _a(base, 0.6), blurRadius: 18)],
        );

    for (final p in _pipes) {
      final gTop = p.gapY - p.gap / 2;
      final gBot = p.gapY + p.gap / 2;
      w.add(Positioned(left: p.x, top: 0, width: _pipeW, height: gTop, child: DecoratedBox(decoration: body())));
      w.add(Positioned(left: p.x - 7, top: gTop - 28, width: _pipeW + 14, height: 28, child: DecoratedBox(decoration: cap())));
      w.add(Positioned(left: p.x, top: gBot, width: _pipeW, height: _groundTop - gBot, child: DecoratedBox(decoration: body())));
      w.add(Positioned(left: p.x - 7, top: gBot, width: _pipeW + 14, height: 28, child: DecoratedBox(decoration: cap())));
      if (!p.coinTaken) {
        w.add(Positioned(
          left: p.x + _pipeW / 2 - 16,
          top: p.gapY - 16 + sin(_time * 4 + p.gapY) * 4,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(max(0.2, cos(_time * 4).abs()), 1, 1),
            child: const Text('🪙', style: TextStyle(fontSize: 30)),
          ),
        ));
      }
    }
    return w;
  }

  Widget _glass({required Widget child, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 10)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _a(Colors.black, 0.28),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _a(Colors.white, 0.25)),
      ),
      child: child,
    );
  }

  TextStyle _txt(double size, {Color color = Colors.white, double spacing = 0}) => TextStyle(
        fontSize: size,
        color: color,
        fontWeight: FontWeight.w900,
        letterSpacing: spacing,
        decoration: TextDecoration.none,
        shadows: [Shadow(color: _a(Colors.black, 0.4), blurRadius: 8, offset: const Offset(0, 2))],
      );

  // ───────────────────────── build ─────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(builder: (context, box) {
        _setup(Size(box.maxWidth, box.maxHeight));
        final shakeOff = Offset((_rng.nextDouble() - 0.5) * 18 * _shake, (_rng.nextDouble() - 0.5) * 18 * _shake);
        final topPad = MediaQuery.of(context).padding.top + 14;
        final body = _palettes[_paletteIdx].body;

        return Focus(
          autofocus: true,
          onKeyEvent: (n, e) {
            if (e is KeyDownEvent && e.logicalKey == LogicalKeyboardKey.space) {
              _tap();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _tap(),
            child: Transform.translate(
              offset: shakeOff,
              child: Stack(children: [
                // Sky
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_top, _bot]),
                    ),
                  ),
                ),
                // Stars
                for (int i = 0; i < _starPos.length; i++)
                  Positioned(
                    left: _starPos[i].dx,
                    top: _starPos[i].dy,
                    child: Opacity(
                      opacity: (_stars * (0.4 + 0.6 * (0.5 + 0.5 * sin(_time * 2 + _starPhase[i])))).clamp(0.0, 1.0),
                      child: const Text('✦', style: TextStyle(color: Colors.white, fontSize: 10, decoration: TextDecoration.none)),
                    ),
                  ),
                // Sun / moon
                Positioned(
                  right: 36 + sin(_time * 0.3) * 8,
                  top: topPad + 70 + cos(_time * 0.25) * 6,
                  child: Text(body, style: const TextStyle(fontSize: 64, decoration: TextDecoration.none)),
                ),
                // Clouds
                for (final c in _clouds)
                  Positioned(
                    left: c.x,
                    top: c.y,
                    child: Opacity(
                      opacity: 0.75 - _stars * 0.45,
                      child: Text('☁️', style: TextStyle(fontSize: c.size, decoration: TextDecoration.none)),
                    ),
                  ),
                // Pipes
                ..._pipeWidgets(),
                // Ground
                Positioned(
                  left: 0, right: 0, bottom: 0, height: _groundH,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [Color(0xFF3E8E41), Color(0xFF5D4037)]),
                      border: Border(top: BorderSide(color: _a(Colors.white, 0.4), width: 3)),
                    ),
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topLeft,
                        minWidth: 0,
                        maxWidth: double.infinity,
                        child: Transform.translate(
                          offset: Offset(-(_groundScroll % 36), 0),
                          child: Row(children: List.generate(
                            (_size.width / 36).ceil() + 3,
                            (_) => const SizedBox(width: 36, child: Text('🌿', style: TextStyle(fontSize: 24, decoration: TextDecoration.none))),
                          )),
                        ),
                      ),
                    ),
                  ),
                ),
                // Bird
                Positioned(
                  left: _birdX - 22,
                  top: _birdY - 22,
                  width: 44,
                  height: 44,
                  child: Transform.rotate(
                    angle: _state == GameState.over ? 1.4 : (_vel / 600).clamp(-0.5, 1.0),
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: _a(Colors.white, 0.28), blurRadius: 24, spreadRadius: 2)]),
                      child: Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.diagonal3Values(_flipBird ? -1 : 1, 1, 1),
                          child: Text(_state == GameState.over ? '😵' : _birdEmoji,
                              style: const TextStyle(fontSize: 36, decoration: TextDecoration.none)),
                        ),
                      ),
                    ),
                  ),
                ),
                // Particles
                for (final p in _parts)
                  Positioned(
                    left: p.x, top: p.y,
                    child: Opacity(opacity: p.life.clamp(0.0, 1.0),
                        child: Text(p.emoji, style: TextStyle(fontSize: p.size, decoration: TextDecoration.none))),
                  ),
                // HUD
                if (_state == GameState.playing)
                  Positioned(
                    top: topPad, left: 0, right: 0,
                    child: Column(children: [
                      Text('$_score', style: _txt(64)),
                      const SizedBox(height: 4),
                      _glass(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text('🪙 $_coins', style: _txt(16)),
                          const SizedBox(width: 14),
                          Text('👑 $_best', style: _txt(16)),
                        ]),
                      ),
                    ]),
                  ),
                if (_state == GameState.ready) _readyOverlay(),
                if (_state == GameState.over) _overOverlay(),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Widget _readyOverlay() {
    final pulse = 0.6 + 0.4 * sin(_time * 4);
    return Positioned.fill(
      child: Align(
        alignment: const Alignment(0, -0.55),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🦉', style: TextStyle(fontSize: 54 + sin(_time * 3) * 4, decoration: TextDecoration.none)),
          Text('SKY DASH', style: _txt(54, spacing: 4)),
          const SizedBox(height: 4),
          Text('by ${StudentCode.getCreatorName()}', style: _txt(16, color: _a(Colors.white, 0.85), spacing: 2)),
          const SizedBox(height: 26),
          Opacity(opacity: pulse, child: _glass(child: Text('TAP TO FLAP 👆', style: _txt(20, spacing: 2)))),
          const SizedBox(height: 14),
          Text('Collect 🪙 • Evolve your bird • Survive the night 🌙', style: _txt(13, color: _a(Colors.white, 0.85))),
        ]),
      ),
    );
  }

  Widget _overOverlay() {
    final t = ((_time - _overAt) * 3).clamp(0.0, 1.0);
    return Positioned.fill(
      child: Center(
        child: Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.85 + 0.15 * t,
            child: _glass(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 26),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('GAME OVER 💥', style: _txt(30, spacing: 2)),
                const SizedBox(height: 12),
                Text(_medal, style: const TextStyle(fontSize: 58, decoration: TextDecoration.none)),
                const SizedBox(height: 8),
                Text('SCORE  $_score', style: _txt(26)),
                const SizedBox(height: 6),
                Text(_newBest ? '👑 NEW BEST!  $_best' : '👑 BEST  $_best',
                    style: _txt(20, color: _newBest ? const Color(0xFFFFD54F) : Colors.white)),
                const SizedBox(height: 6),
                Text('🪙 $_coins collected', style: _txt(16, color: _a(Colors.white, 0.9))),
                const SizedBox(height: 18),
                Opacity(opacity: 0.6 + 0.4 * sin(_time * 4),
                    child: Text('TAP TO RETRY 🔁', style: _txt(18, spacing: 2))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}