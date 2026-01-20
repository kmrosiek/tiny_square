import 'dart:ui';

import '../../domain/services/brightness_provider.dart';

class PlatformBrightnessProvider implements BrightnessProvider {
  @override
  Brightness get currentBrightness => PlatformDispatcher.instance.platformBrightness;
}
