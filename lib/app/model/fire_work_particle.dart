import 'package:flutter/animation.dart';

class FireworkParticle {
  Offset position;
  double speedX;
  double speedY;
  Color color;
  double size;
  double life;
  List<TrailParticle> trailParticles = []; // 拖尾粒子列表

  FireworkParticle({
    required this.position,
    required this.speedX,
    required this.speedY,
    required this.color,
    required this.size,
    required this.life,
  });

  void update() {
    // 更新主粒子的位置和速度（考虑重力和空气阻力）
    position = Offset(position.dx + speedX, position.dy + speedY);
    speedY += 0.1; // 重力加速度
    speedX *= 0.99; // 空气阻力
    speedY *= 0.99;
    life -= 0.01; // 减少生命值
    color = color.withOpacity(life.clamp(0.0, 1.0)); // 透明度随生命值变化

    // 生成拖尾粒子（每帧生成一个）
    if (life > 0) {
      trailParticles.add(TrailParticle(
        position: position,
        color: color.withOpacity(0.5), // 拖尾粒子初始透明度较低
        size: size * 0.8, // 拖尾粒子初始大小较小
        life: 0.3, // 拖尾粒子的生命周期较短
      ));
    }

    // 更新拖尾粒子状态
    for (var trail in trailParticles) {
      trail.update();
    }
    // 移除生命值耗尽的拖尾粒子
    trailParticles.removeWhere((trail) => trail.life <= 0);
  }
}

class TrailParticle {
  Offset position;
  Color color;
  double size;
  double life;

  TrailParticle({
    required this.position,
    required this.color,
    required this.size,
    required this.life,
  });

  void update() {
    life -= 0.05; // 拖尾粒子快速消散
    color = color.withOpacity(life.clamp(0.0, 1.0)); // 透明度随生命值变化
  }
}