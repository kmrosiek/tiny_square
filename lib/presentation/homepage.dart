import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tiny_square/presentation/widgets/animated_loading_border/animated_loading_border.dart';
import 'package:tiny_square/presentation/widgets/image_or_error_message.dart';
import 'package:tiny_square/presentation/widgets/theme_toggle.dart';
import '../application/image/image_cubit.dart';
import '../application/image/image_state.dart';
import 'widgets/next_button.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final theme = Theme.of(context);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final colors = state.extractedColors;
        final hasColors = colors != null;

        final backgroundColor = hasColors
            ? (isDarkMode ? colors.darkBackground : colors.lightBackground) ?? Theme.of(context).scaffoldBackgroundColor
            : Theme.of(context).scaffoldBackgroundColor;

        final textColor = hasColors
            ? (isDarkMode ? colors.darkTextColor : colors.lightTextColor) ?? Theme.of(context).colorScheme.onSurface
            : Theme.of(context).colorScheme.onSurface;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          color: theme.scaffoldBackgroundColor,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Center(
                            child: AnimatedLoadingBorder(
                              isLoading: state.isLoading,
                              borderColor: textColor,
                              child: ImageOrErrorMessage(
                                isLoading: state.isLoading,
                                errorMessage: state.errorMessage,
                                imageBytes: state.imageBytes,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        NextButton(
                          onPressed: () => context.read<ImageCubit>().fetchRandomImage(),
                          isLoading: state.isLoading,
                          backgroundColor: backgroundColor,
                          foregroundColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(top: 8, right: 8, child: ThemeToggle(iconColor: textColor)),
              ],
            ),
          ),
        );
      },
    );
  }
}
