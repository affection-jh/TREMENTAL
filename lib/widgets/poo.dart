import 'package:flutter/material.dart';

/// 곰돌이 포즈 타입
enum PooPose {
  lying, // 누워있음
  sitting, // 앉아있음
  standing, // 서있음
}

/// 곰돌이 캐릭터 위젯 (이미지/GIF 기반)
class Poo extends StatelessWidget {
  final double? width;
  final double? height;
  final PooPose pose;
  final BoxFit fit;

  const Poo({
    super.key,
    this.width,
    this.height,
    this.pose = PooPose.sitting,
    this.fit = BoxFit.contain,
  });

  String _getAssetPath() {
    switch (pose) {
      case PooPose.lying:
        return 'assets/images/poo_lying.png';
      case PooPose.sitting:
        return 'assets/images/poo_sitting.png';
      case PooPose.standing:
        return 'assets/images/poo_standing.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _getAssetPath(),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('이미지 로드 실패: ${_getAssetPath()}');
        debugPrint('에러: $error');
        return Container(
          width: width ?? 200,
          height: height ?? 200,
          color: Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_not_supported, size: 48),
              const SizedBox(height: 8),
              Text('이미지 없음\n${_getAssetPath()}'),
            ],
          ),
        );
      },
    );
  }
}
