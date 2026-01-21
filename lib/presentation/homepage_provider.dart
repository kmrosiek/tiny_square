import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/image/image_cubit.dart';
import '../core/di/injection.dart';
import 'homepage.dart';

class HomepageProvider extends StatelessWidget {
  const HomepageProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => getIt<ImageCubit>()..fetchNextImage(), child: const Homepage());
  }
}
