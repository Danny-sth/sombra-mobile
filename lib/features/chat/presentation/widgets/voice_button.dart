import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';

class VoiceButton extends StatefulWidget {
  final bool isRecording;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;

  const VoiceButton({
    super.key,
    required this.isRecording,
    required this.isLoading,
    required this.onTap,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  @override
  State<VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<VoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onTap,
      onLongPressStart: widget.isLoading ? null : (_) {
        HapticFeedback.mediumImpact();
        widget.onLongPressStart();
      },
      onLongPressEnd: (_) => widget.onLongPressEnd(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse rings when recording
              if (widget.isRecording) ...[
                _buildPulseRing(0.0),
                _buildPulseRing(0.33),
                _buildPulseRing(0.66),
              ],

              // Main button
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.isRecording
                        ? [AppColors.error, AppColors.error.withOpacity(0.8)]
                        : [AppColors.gradientStart, AppColors.gradientEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (widget.isRecording ? AppColors.error : AppColors.primary)
                          .withOpacity(0.4),
                      blurRadius: widget.isRecording ? 24 : 16,
                      spreadRadius: widget.isRecording ? 4 : 0,
                    ),
                  ],
                ),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : Icon(
                          widget.isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          color: Colors.white,
                          size: 36,
                        ),
                ),
              ),
            ],
          );
        },
      ),
    ).animate(target: widget.isRecording ? 1 : 0).scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 200.ms,
        );
  }

  Widget _buildPulseRing(double delayFactor) {
    final value = (_pulseController.value + delayFactor) % 1.0;
    final scale = 1.0 + value * 0.5;
    final opacity = (1.0 - value) * 0.3;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.error.withOpacity(opacity),
            width: 3,
          ),
        ),
      ),
    );
  }
}
