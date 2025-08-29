import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// --- Modelos para as Partículas ---

/// Modelo para uma partícula da animação de explosão (estrela).
class _Star {
  final Color color;
  final double initialAngle;
  final double maxDistance;
  final double initialRotation;
  final double finalRotation;

  _Star({
    required this.color,
    required this.initialAngle,
    required this.maxDistance,
    required this.initialRotation,
    required this.finalRotation,
  });
}

/// Modelo para uma partícula da animação de queda (rosto triste).
class _FallingFace {
  final double startX;
  final double size;
  final double rotation;
  // Atraso de início (0.0 a 1.0), representa o ponto na animação principal em que a queda começa.
  final double startDelay;

  _FallingFace({
    required this.startX,
    required this.size,
    required this.rotation,
    required this.startDelay,
  });
}

// --- Widget Principal ---

/// Um widget que exibe uma animação de feedback
class FeedbackAnimationWidget extends StatefulWidget {
  const FeedbackAnimationWidget({super.key});

  @override
  State<FeedbackAnimationWidget> createState() => FeedbackAnimationWidgetState();
}

enum AnnimationType { starts, sadFace }

class FeedbackAnimationWidgetState extends State<FeedbackAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();

  final List<_Star> _stars = [];
  final List<_FallingFace> _sadFaces = [];

  bool _isStarsAnimation = true;

  final List<Color> _starColors = [
    Colors.yellow.shade600,
    Colors.amber.shade400,
    Colors.white,
    Colors.lightBlue.shade200,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Inicia uma animação de feedback.
  void execute({
    required AnnimationType annimationType,
    required int particleCount,
    double duration = 3.0, // Aumentei a duração padrão para a chuva ficar mais suave
    double explosionArea = 200.0,
  }) {
    if (_controller.isAnimating) {
      _controller.stop();
    }

    setState(() => _isStarsAnimation = annimationType == AnnimationType.starts);

    _controller.duration = Duration(milliseconds: (duration * 1000).toInt());

    _stars.clear();
    _sadFaces.clear();

    if (annimationType == AnnimationType.starts) {
      // Lógica para criar estrelas (inalterada)
      for (int i = 0; i < particleCount; i++) {
        _stars.add(
          _Star(
            color: _starColors[_random.nextInt(_starColors.length)],
            initialAngle: _random.nextDouble() * 2 * pi,
            maxDistance: _random.nextDouble() * (explosionArea * 0.75) + (explosionArea * 0.25),
            initialRotation: _random.nextDouble() * 2 * pi,
            finalRotation: _random.nextDouble() * 4 * pi,
          ),
        );
      }
    } else {
      // Lógica para criar rostos tristes
      for (int i = 0; i < particleCount; i++) {
        _sadFaces.add(
          _FallingFace(
            startX: _random.nextDouble(),
            size: _random.nextDouble() * 20 + 20,
            rotation: _random.nextDouble() * pi - (pi / 2),
            startDelay: _random.nextDouble() * 0.2,
          ),
        );
      }
    }

    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (!_controller.isAnimating && _controller.value == 0.0) {
              return const SizedBox.shrink();
            }

            return _isStarsAnimation
                ? _buildStarExplosion(constraints)
                : _buildSadFaceRain(constraints);
          },
        );
      },
    );
  }

  /// Constrói a animação de explosão de estrelas.
  Widget _buildStarExplosion(BoxConstraints constraints) {
    final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    final progress = _controller.value;
    final opacity = 1.0 - CurvedAnimation(parent: _controller, curve: Curves.easeIn).value;

    return Stack(
      clipBehavior: Clip.none,
      children: _stars.map((star) {
        final currentDistance = star.maxDistance * progress;
        final x = center.dx + cos(star.initialAngle) * currentDistance;
        final y = center.dy + sin(star.initialAngle) * currentDistance;
        final rotation =
            star.initialRotation + (star.finalRotation - star.initialRotation) * progress;
        final scale = sin(progress * pi);

        return Positioned(
          left: x - 15,
          top: y - 15,
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Icon(Icons.star, color: star.color, size: 30),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Constrói a animação de chuva de rostos tristes.
  Widget _buildSadFaceRain(BoxConstraints constraints) {
    final mainProgress = _controller.value;

    return Stack(
      children: _sadFaces.map((face) {
        // Se a animação principal ainda não atingiu o delay desta carinha, não a desenha.
        if (mainProgress < face.startDelay) {
          return const SizedBox.shrink();
        }

        // Calcula o progresso individual desta carinha (de 0.0 a 1.0)
        // após o seu tempo de atraso ter passado.
        final lifeSpan = 1.0 - face.startDelay;
        final faceProgress = ((mainProgress - face.startDelay) / lifeSpan).clamp(0.0, 1.0);

        final opacity = sin(faceProgress * pi);
        final y = faceProgress * (constraints.maxHeight + face.size);
        final x = face.startX * constraints.maxWidth;

        return Positioned(
          left: x,
          top: y - face.size,
          child: Transform.rotate(
            angle: face.rotation,
            child: Opacity(
              opacity: opacity,
              child: Icon(
                FontAwesomeIcons.solidFaceSadTear,
                color: Theme.of(context).colorScheme.error,
                size: face.size,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
