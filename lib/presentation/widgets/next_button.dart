import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class NextButton extends StatelessWidget {
  const NextButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final VoidCallback onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: !isLoading,
      label: isLoading ? 'Loading new image' : 'Load another image',
      child: SizedBox(
        width: double.infinity,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56),
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              disabledBackgroundColor: backgroundColor,
              disabledForegroundColor: foregroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: isLoading
                ? ExcludeSemantics(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: LoadingAnimationWidget.staggeredDotsWave(color: foregroundColor, size: 24),
                    ),
                  )
                : Text(
                    'Another',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: foregroundColor),
                  ),
          ),
        ),
      ),
    );
  }
}
