import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/image/image_cubit.dart';
import '../application/image/image_state.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        final hasImage = state.imageUrl != null;
        final backgroundColor = hasImage ? state.backgroundColor : Theme.of(context).scaffoldBackgroundColor;

        final textColor = hasImage ? state.textColor : Theme.of(context).colorScheme.onSurface;

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
                      Expanded(child: Center(child: _buildImageSection(context, state))),
                      const SizedBox(height: 24),
                      _buildButton(context, state, textColor),
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

  Widget _buildImageSection(BuildContext context, ImageState state) {
    if (state.isLoading && state.imageUrl == null) {
      return const _LoadingIndicator();
    }

    if (state.errorMessage != null && state.imageUrl == null) {
      return _ErrorDisplay(message: state.errorMessage!);
    }

    if (state.imageUrl != null) {
      return _ImageDisplay(imageUrl: state.imageUrl!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildButton(BuildContext context, ImageState state, Color textColor) {
    return Semantics(
      button: true,
      label: 'Load another random image',
      child: ElevatedButton(
        onPressed: state.isLoading ? null : () => context.read<ImageCubit>().loadImage(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          backgroundColor: textColor.withValues(alpha: 0.15),
          foregroundColor: textColor,
        ),
        child: state.isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(textColor)),
              )
            : Text(
                'Another',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
              ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

class _ImageDisplay extends StatefulWidget {
  const _ImageDisplay({required this.imageUrl});

  final String imageUrl;

  @override
  State<_ImageDisplay> createState() => _ImageDisplayState();
}

class _ImageDisplayState extends State<_ImageDisplay> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.maxWidth < constraints.maxHeight ? constraints.maxWidth : constraints.maxHeight * 0.8;

        return Semantics(
          image: true,
          label: 'Random landscape image',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: size,
              height: size,
              child: CachedNetworkImage(
                imageUrl: widget.imageUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) =>
                    Container(color: Colors.grey.shade300, child: const Icon(Icons.error, size: 48)),
                imageBuilder: (context, imageProvider) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.read<ImageCubit>().updateColorsFromImage(imageProvider);
                  });
                  return Image(image: imageProvider, fit: BoxFit.cover);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  const _ErrorDisplay({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 16),
        Text('Failed to load image', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 16),
        TextButton(onPressed: () => context.read<ImageCubit>().loadImage(), child: const Text('Retry')),
      ],
    );
  }
}
