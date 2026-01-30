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
        return Stack(
          children: [
            child,
            if (overlayProvider.isVisible)
              AnimatedOpacity(
                opacity: overlayProvider.isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: overlay ?? const SizedBox(),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
