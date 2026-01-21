import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:tiny_square/application/theme/theme_cubit.dart';
import 'package:tiny_square/domain/services/brightness_provider.dart';
import 'package:tiny_square/infrastructure/services/platform_brightness_provider.dart';
import '../../application/image/image_cubit.dart';
import '../../domain/repositories/image_repository.dart';
import '../../domain/services/color_extractor.dart';
import '../../infrastructure/datasources/image_remote_datasource.dart';
import '../../infrastructure/repositories/image_repository_impl.dart';
import '../../infrastructure/services/color_extractor_impl.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt
    ..registerLazySingleton<http.Client>(http.Client.new)
    // Data sources
    ..registerLazySingleton<ImageRemoteDataSource>(() => ImageRemoteDataSourceImpl(client: getIt<http.Client>()))
    // Services
    ..registerLazySingleton<BrightnessProvider>(PlatformBrightnessProvider.new)
    ..registerLazySingleton<ColorExtractor>(ColorExtractorImpl.new)
    // Repositories
    ..registerLazySingleton<ImageRepository>(
      () => ImageRepositoryImpl(dataSource: getIt<ImageRemoteDataSource>(), colorExtractor: getIt<ColorExtractor>()),
    )
    // Cubits
    ..registerFactory<ImageCubit>(() => ImageCubit(repository: getIt<ImageRepository>()))
    ..registerFactory<ThemeCubit>(() => ThemeCubit(brightnessProvider: getIt<BrightnessProvider>()));
}
