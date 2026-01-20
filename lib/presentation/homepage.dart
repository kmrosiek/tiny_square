import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/image/image_cubit.dart';
import '../application/image/image_state.dart';
import 'widgets/error_display.dart';
import 'widgets/image_display.dart';
import 'widgets/next_button.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
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
          color: backgroundColor,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: Center(child: _buildImageSection(state))),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection(ImageState state) {
    if (state.isLoading && state.imageBytes == null) {
      return const CircularProgressIndicator();
    }

    if (state.errorMessage != null && state.imageBytes == null) {
      return ErrorDisplay(message: state.errorMessage!);
    }

    if (state.imageBytes != null) {
      return ImageDisplay(imageBytes: state.imageBytes!);
    }

    return const SizedBox.shrink();
  }
}
