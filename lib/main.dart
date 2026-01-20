import 'package:flutter/material.dart';
import 'package:tiny_square/application/theme/app_theme.dart';
import 'package:tiny_square/presentation/homepage_provider.dart';
import 'core/di/injection.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tiny Square',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const HomepageProvider(),
    );
  }
}
