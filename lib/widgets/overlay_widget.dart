import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/overlay_provider.dart';

class OverlayWidget extends StatelessWidget {
  final Widget child;
  final Widget? overlay;

  const OverlayWidget({super.key, required this.child, this.overlay});

  @override
  Widget build(BuildContext context) {
    return Consumer<OverlayProvider>(
      builder: (context, overlayProvider, _) {
        final effectiveOverlay = overlay ?? overlayProvider.overlay;
        return Stack(
          children: [
            child,
            if (overlayProvider.isVisible && effectiveOverlay != null)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Material(
                    color: Colors.transparent,
                    child: AnimatedOpacity(
                      opacity: overlayProvider.isVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: Stack(
                        children: [
                          // 블러 + 딤(배경만)
                          Positioned.fill(
                            child: ClipRect(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 10,
                                  sigmaY: 10,
                                ),
                                child: Container(
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ),
                          // 블러 위에 overlay 표시
                          Positioned.fill(child: effectiveOverlay),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
