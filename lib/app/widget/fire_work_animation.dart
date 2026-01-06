import 'package:flutter/material.dart';
import 'dart:math';

class GlobalFirework {
  static void show(BuildContext context) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    // 从屏幕底部中心发射
    final startPosition = Offset(
      MediaQuery.of(context).size.width / 2,
      MediaQuery.of(context).size.height,
    );

    overlayEntry = OverlayEntry(
      builder: (context) => FireworkAnimation(startPosition: startPosition),
    );

    overlay.insert(overlayEntry);

    // 动画持续5秒后移除（缩短时间以减少粒子存活）
    Future.delayed(const Duration(seconds: 5), () {
      overlayEntry.remove();
      overlayEntry.dispose();
    });
  }
}

class FireworkAnimation extends StatefulWidget {
  final Offset startPosition;

  const FireworkAnimation({super.key, required this.startPosition});

  @override
  _FireworkAnimationState createState() => _FireworkAnimationState();
}

class _FireworkAnimationState extends State<FireworkAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<FireworkParticle> particles = [];
  List<TrailParticle> trailParticles = [];
  Offset? launchPosition;
  Offset? burstPosition;
  bool isBursting = false;
  final List<Color> rainbowColors = [
    Color(0xFFff6213),
    Color(0xFFffb742),
    Color(0xFFfff4a5),
    Colors.red,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // 缩短为5秒
    )..addListener(() {
        setState(() {
          if (!isBursting) {
            updateLaunch();
          } else {
            updateParticles();
          }
          updateTrail();
        });
      });

    launchPosition = widget.startPosition;
    _controller.forward();
  }

  void updateLaunch() {
    if (launchPosition != null) {
      final targetY = MediaQuery.of(context).size.height * 0.3;
      final random = Random();
      final tiltAngle = (random.nextDouble() * 0.4) - 0.2;
      final baseAngle = (pi / 2) + tiltAngle;
      final speed = 15 * (1 - _controller.value);

      launchPosition = Offset(
        launchPosition!.dx +
            cos(baseAngle) * speed +
            (random.nextDouble() - 0.5),
        launchPosition!.dy - sin(baseAngle) * speed,
      );

      // 添加上升阶段拖尾粒子（减少数量）
      for (int i = 0; i < 1; i++) {
        final color = rainbowColors[random.nextInt(rainbowColors.length)];
        trailParticles.add(TrailParticle(
          position: launchPosition!,
          color: color.withOpacity(random.nextDouble() * 0.5 + 0.5),
          size: 1.0 + random.nextDouble() * 2,
          direction: Offset(0, -1),
        ));
      }

      if (launchPosition!.dy <= targetY) {
        burstPosition = launchPosition;
        createFireworkParticles();
        isBursting = true;
        launchPosition = null;
      }
    }
  }

  void createFireworkParticles() {
    final random = Random();
    for (int i = 0; i < 20; i++) {
      // 减少到20个粒子
      final angle = random.nextDouble() * 2 * pi;
      final speed = 5 + random.nextDouble() * 5;
      final color = rainbowColors[random.nextInt(rainbowColors.length)];
      final brightness = 0.3 + random.nextDouble() * 0.7;
      particles.add(FireworkParticle(
        position: burstPosition!,
        speedX: cos(angle) * speed,
        speedY: sin(angle) * speed,
        color: color,
        size: 3.0,
        life: 1.5,
        brightness: brightness,
      ));
    }
  }

  void updateParticles() {
    final random = Random();
    for (var particle in particles) {
      particle.speedX += (random.nextDouble() - 0.5) * 0.1; // 减少扰动幅度
      particle.speedY += (random.nextDouble() - 0.5) * 0.1;
      particle.speedX *= 0.975;
      particle.speedY *= 0.975;
      particle.speedY += 0.09;
      particle.position = Offset(
        particle.position.dx + particle.speedX,
        particle.position.dy + particle.speedY,
      );
      particle.life -= 0.010; // 加速衰减
      double opacity = (particle.life * particle.brightness).clamp(0.0, 1.0);
      particle.color = particle.color.withOpacity(opacity);

      // 为爆炸粒子添加尾焰效果（减少到1个）
      if (particle.life > 0) {
        for (int i = 0; i < 2; i++) {
          trailParticles.add(TrailParticle(
              position: particle.position,
              color: particle.color
                  .withOpacity(particle.life * particle.brightness * 0.5),
              size: 1.0 + random.nextDouble() * 1.5,
              direction:
                  Offset(-particle.speedX, -particle.speedY).scale(0.1, 0.1)));
        }
      }
    }
    particles.removeWhere((p) => p.life <= 0);
  }

  void updateTrail() {
    for (var particle in trailParticles) {
      particle.update();
    }
    trailParticles.removeWhere((p) => p.life <= 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
        child: IgnorePointer(
            child: CustomPaint(
      painter: FireworkPainter(particles, trailParticles, launchPosition),
      size: Size.infinite,
    )));
  }
}

class FireworkParticle {
  Offset position;
  double speedX;
  double speedY;
  Color color;
  double size;
  double life;
  double brightness;

  FireworkParticle({
    required this.position,
    required this.speedX,
    required this.speedY,
    required this.color,
    required this.size,
    required this.life,
    required this.brightness,
  });
}

class TrailParticle {
  Offset position;
  double life;
  Color color;
  double size;
  Offset direction;

  TrailParticle({
    required this.position,
    required this.color,
    required this.size,
    required this.direction,
    this.life = 0.5,
  });

  void update() {
    life -= 0.03;
    color = color.withOpacity(life.clamp(0.0, 1.0));
  }
}

class FireworkPainter extends CustomPainter {
  final List<FireworkParticle> particles;
  final List<TrailParticle> trailParticles;
  final Offset? launchPosition;

  FireworkPainter(this.particles, this.trailParticles, this.launchPosition);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    // 绘制尾焰粒子（细长彩带）
    for (var particle in trailParticles) {
      final paint = Paint()
        ..color = particle.color
        ..strokeWidth = particle.size
        ..strokeCap = StrokeCap.round;
      final end = particle.position - particle.direction * 20;
      canvas.drawLine(particle.position, end, paint);
    }

    // 绘制上升阶段主体（无模糊）
    if (launchPosition != null) {
      final paint = Paint()
        ..color = Colors.yellow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawCircle(launchPosition!, 5.0, paint);
    }

    // 绘制爆炸粒子（动态弧形彩带）
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color
        ..strokeWidth = particle.size
        ..strokeCap = StrokeCap.round;
      final path = Path();
      path.moveTo(particle.position.dx, particle.position.dy);
      final controlPoint = Offset(
        particle.position.dx + particle.speedX * 10 * particle.life,
        particle.position.dy + particle.speedY * 10 * particle.life,
      );
      final endPoint = Offset(
        particle.position.dx + particle.speedX * 30 * particle.life,
        particle.position.dy + particle.speedY * 30 * particle.life,
      );
      path.quadraticBezierTo(
          controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // 优化时可考虑更精细的重绘条件
  }
}
