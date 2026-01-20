import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/image/image_cubit.dart';
import '../../application/image/image_state.dart';

class NextButton extends StatelessWidget {
  const NextButton({required this.textColor, super.key});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageCubit, ImageState>(
      builder: (context, state) {
        return Semantics(
          button: true,
          label: 'Load another random image',
          child: ElevatedButton(
            onPressed: state.isLoading ? null : () => context.read<ImageCubit>().fetchRandomImage(),
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
      },
    );
  }
}
